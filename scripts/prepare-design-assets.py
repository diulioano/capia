"""Prepare Capia resources without changing the original design.

Run from any directory. --check reads only and requires no network.
"""
import argparse
import base64
import gzip
import hashlib
import io
import json
from pathlib import Path
import re
import shutil
import urllib.request

from PIL import Image
from collections import deque
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

ROOT = Path(__file__).resolve().parents[1]
RESOURCES = ROOT / 'ios/Capia/Sources/Capia/Resources'
DESIGN = next((ROOT / 'design').glob('*.html'))
REVISION = '38411257417e616c5d4daa1b9e91a3dbcebe1c2e'
FONT_ROOT = f'https://raw.githubusercontent.com/google/fonts/{REVISION}/ofl'
FONTS = {
    'Figtree.ttf': 'figtree/Figtree[wght].ttf',
    'Figtree-OFL.txt': 'figtree/OFL.txt',
    'ZenMaruGothic-Bold.ttf': 'zenmarugothic/ZenMaruGothic-Bold.ttf',
    'ZenMaruGothic-OFL.txt': 'zenmarugothic/OFL.txt',
}
MASCOT = 'c98bf460-1310-48cf-b12a-570d347b97de'
STATIC_FONTS = {'Regular': 400, 'SemiBold': 600, 'Bold': 700}
POSES = {'CalmCapybara': (0, 0, 'calma'),
         'ThinkingCapybara': (2, 0, 'pensando'),
         'HappyCapybara': (1, 0, 'feliz'),
         'CelebratingCapybara': (1, 1, 'comemora')}
ICON_SOURCE = ROOT / 'assets/capia-app-icon-generated.png'
ICON_PROMPT = ROOT / 'assets/capia-app-icon-prompt.txt'
ICON = ROOT / 'ios/Capia/Resources/AppIcon.png'


def pose_image(column, row):
    with Image.open(ROOT / 'assets/capybara-expressions-sheet-3x2.png') as sheet:
        image = sheet.crop((column * 512, row * 512, (column + 1) * 512, (row + 1) * 512)).convert('RGBA')
    pixels = image.load()
    pending = deque([(x, y) for x in range(512) for y in (0, 511)] +
                    [(x, y) for y in range(512) for x in (0, 511)])
    seen = set()
    while pending:
        x, y = pending.popleft()
        if not (0 <= x < 512 and 0 <= y < 512) or (x, y) in seen:
            continue
        seen.add((x, y))
        r, g, b, _ = pixels[x, y]
        if min(r, g, b) < 235 or max(r, g, b) - min(r, g, b) > 20:
            continue
        pixels[x, y] = (r, g, b, 0)
        pending.extend(((x-1,y), (x+1,y), (x,y-1), (x,y+1)))
    return image.crop(image.getbbox())


def digest(data):
    return hashlib.sha256(data).hexdigest()


def welcome_bytes():
    manifest = json.loads(re.search(
        r'<script type="__bundler/manifest">(.*?)</script>',
        DESIGN.read_text(encoding='utf-8'), re.S)[1])
    page = manifest['d017ec14-a843-4b61-ab79-5bedc20a48eb']
    data = base64.b64decode(page['data'])
    if page.get('compressed'):
        data = gzip.decompress(data)
    nested = json.loads(re.search(
        r'<script type="__bundler/manifest">(.*?)</script>', data.decode(), re.S)[1])
    asset = nested[MASCOT]
    data = base64.b64decode(asset['data'])
    return gzip.decompress(data) if asset.get('compressed') else data


def prepare():
    (RESOURCES / 'Images').mkdir(parents=True, exist_ok=True)
    (RESOURCES / 'Fonts').mkdir(parents=True, exist_ok=True)
    origins = {}
    image = RESOURCES / 'Images/WelcomeCapybara.png'
    with Image.open(io.BytesIO(welcome_bytes())) as original:
        original.save(image, format='PNG')
    origins[image] = f'{DESIGN.relative_to(ROOT).as_posix()} / {MASCOT}; WEBP → PNG, sem edição visual'
    image = RESOURCES / 'Images/OnsenWallpaper.png'
    shutil.copyfile(ROOT / 'assets/onsen-wallpaper-1170x2532.png', image)
    origins[image] = 'assets/onsen-wallpaper-1170x2532.png; cópia sem alteração'
    for name, (column, row, mood) in POSES.items():
        image = RESOURCES / f'Images/{name}.png'
        pose_image(column, row).save(image)
        origins[image] = (f'assets/capybara-expressions-sheet-3x2.png; célula ({column}, {row}), '
                         f'pose {mood}; recorte e remoção do fundo branco conectado à borda; '
                         'alternativa aos /_blob ausentes no componente Capivara do HTML')
    for name, remote in FONTS.items():
        url = f'{FONT_ROOT}/{remote}'
        target = RESOURCES / 'Fonts' / name
        with urllib.request.urlopen(url) as response:
            target.write_bytes(response.read())
        origins[target] = url
    for style, weight in STATIC_FONTS.items():
        font = TTFont(RESOURCES / 'Fonts/Figtree.ttf', recalcTimestamp=False)
        instance = instantiateVariableFont(font, {'wght': weight}, inplace=True, updateFontNames=True)
        target = RESOURCES / f'Fonts/Figtree-{style}.ttf'
        instance.save(target)
        origins[target] = f'{FONT_ROOT}/{FONTS["Figtree.ttf"]}; instância estática wght={weight}, sem subset'
    records = {p.relative_to(RESOURCES).as_posix(): {
        'sha256': digest(p.read_bytes()), 'origin': origin
    } for p, origin in origins.items()}
    metadata = {'design_sha256': digest(DESIGN.read_bytes()),
                'google_fonts_revision': REVISION, 'files': records}
    metadata['expressions_sheet_sha256'] = digest((ROOT / 'assets/capybara-expressions-sheet-3x2.png').read_bytes())
    with Image.open(ICON_SOURCE) as original:
        original.convert('RGB').resize((1024, 1024), Image.Resampling.LANCZOS).save(ICON)
    metadata['icon'] = {'path': ICON.relative_to(ROOT).as_posix(),
                        'sha256': digest(ICON.read_bytes()),
                        'source': ICON_SOURCE.relative_to(ROOT).as_posix(),
                        'source_sha256': digest(ICON_SOURCE.read_bytes()),
                        'prompt_sha256': digest(ICON_PROMPT.read_bytes()),
                        'original_sha256': digest((ROOT / 'assets/capybara-onsen.png').read_bytes())}
    (RESOURCES / 'sources.json').write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    lines = ['# Recursos do Capia (Get Started e configuração inicial)', '',
             'HTML original e licenças incorporadas preservados. Fontes completas, distribuídas sob OFL 1.1.',
             f'Revisão Google Fonts: `{REVISION}`.', '',
             f'HTML SHA-256: `{metadata["design_sha256"]}`.', '']
    lines += [f'Folha de expressões SHA-256: `{metadata["expressions_sheet_sha256"]}`.', '']
    for path, record in records.items():
        lines += [f'## {path}', '', record['origin'], '', f'SHA-256: `{record["sha256"]}`.', '']
    lines += ['## Ícone instalado', '',
              'Edição por image_gen a partir de assets/capybara-onsen.png. Original gerado em assets/capia-app-icon-generated.png; prompt integral em assets/capia-app-icon-prompt.txt.',
              'Normalização técnica: 1254 × 1254 RGB → 1024 × 1024 RGB, sem máscara de cantos.', '']
    lines += [f'{key}: `{value}`' for key, value in metadata['icon'].items()]
    lines += ['']
    (RESOURCES / 'SOURCES.md').write_text('\n'.join(lines), encoding='utf-8')


def check():
    metadata = json.loads((RESOURCES / 'sources.json').read_text(encoding='utf-8'))
    assert digest(DESIGN.read_bytes()) == metadata['design_sha256'], 'HTML alterado'
    icon = metadata['icon']
    assert icon['path'] == ICON.relative_to(ROOT).as_posix(), 'Caminho do ícone divergente'
    assert icon['sha256'] == digest(ICON.read_bytes()), 'Ícone alterado'
    assert icon['source_sha256'] == digest(ICON_SOURCE.read_bytes()), 'Fonte do ícone alterada'
    assert icon['prompt_sha256'] == digest(ICON_PROMPT.read_bytes()), 'Prompt do ícone alterado'
    assert icon['original_sha256'] == digest((ROOT / 'assets/capybara-onsen.png').read_bytes()), 'Imagem original do ícone alterada'
    with Image.open(ICON) as image:
        assert image.format == 'PNG' and image.size == (1024, 1024), 'Formato/dimensão do ícone incorretos'
        assert image.mode == 'RGB' or (image.mode == 'RGBA' and image.getchannel('A').getextrema() == (255, 255)), 'Ícone não é opaco'
        with Image.open(ICON_SOURCE) as source:
            expected = source.convert('RGB').resize((1024, 1024), Image.Resampling.LANCZOS)
            assert image.convert('RGB').tobytes() == expected.tobytes(), 'Ícone divergente da origem'
    required = {'Images/WelcomeCapybara.png', 'Images/OnsenWallpaper.png'} | {
        f'Fonts/{name}' for name in FONTS} | {f'Fonts/Figtree-{style}.ttf' for style in STATIC_FONTS} | {f'Images/{name}.png' for name in POSES}
    assert set(metadata['files']) == required, 'Manifesto de recursos incompleto'
    assert metadata['expressions_sheet_sha256'] == digest((ROOT / 'assets/capybara-expressions-sheet-3x2.png').read_bytes()), 'Folha de expressões alterada'
    for name, (column, row, _) in POSES.items():
        with Image.open(RESOURCES / f'Images/{name}.png') as image:
            expected = pose_image(column, row)
            assert image.mode == 'RGBA' and image.size == expected.size and image.tobytes() == expected.tobytes(), f'Pose divergente: {name}'
            assert image.getchannel('A').getextrema() == (0, 255), f'Recorte opaco: {name}'
    sources = (RESOURCES / 'SOURCES.md').read_text(encoding='utf-8')
    assert all(str(value) in sources for value in icon.values()), 'Origem do ícone não documentada'
    for path, record in metadata['files'].items():
        data = (RESOURCES / path).read_bytes()
        assert digest(data) == record['sha256'], f'Hash divergente: {path}'
        assert record['sha256'] in sources and record['origin'] in sources, f'Origem ausente: {path}'
        if path.endswith('.ttf'):
            assert data[:4] == b'\x00\x01\x00\x00', f'TTF inválida: {path}'
            font = TTFont(io.BytesIO(data))
            if 'Figtree-' in path:
                assert font['name'].getDebugName(6) == Path(path).stem, f'Nome nativo incorreto: {path}'
        if path.endswith('OFL.txt'):
            assert b'SIL OPEN FONT LICENSE' in data, f'Licença ausente: {path}'
    with Image.open(RESOURCES / 'Images/WelcomeCapybara.png') as image:
        assert image.size == (480, 410), 'Dimensão incorreta da capivara'
        with Image.open(io.BytesIO(welcome_bytes())) as original:
            assert image.convert('RGBA').tobytes() == original.convert('RGBA').tobytes(), 'Capivara divergente do HTML'
    assert (RESOURCES / 'Images/OnsenWallpaper.png').read_bytes() == (ROOT / 'assets/onsen-wallpaper-1170x2532.png').read_bytes(), 'Fundo divergente'
    with Image.open(RESOURCES / 'Images/OnsenWallpaper.png') as image:
        assert image.size == (1170, 2532), 'Dimensão incorreta do fundo'
    print('Capia: imagens, poses (calma, pensando, feliz, comemora), fontes, licenças, ícone opaco 1024 e hashes conferidos.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Somente leitura, sem rede')
    args = parser.parse_args()
    if not args.check:
        prepare()
    check()
