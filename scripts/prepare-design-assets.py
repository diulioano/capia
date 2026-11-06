"""Prepare US1 resources without changing the original design. Requires Pillow.

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
    (RESOURCES / 'sources.json').write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    lines = ['# Recursos das boas-vindas (US1)', '',
             'HTML original e licenças incorporadas preservados. Fontes completas, distribuídas sob OFL 1.1.',
             f'Revisão Google Fonts: `{REVISION}`.', '',
             f'HTML SHA-256: `{metadata["design_sha256"]}`.', '']
    for path, record in records.items():
        lines += [f'## {path}', '', record['origin'], '', f'SHA-256: `{record["sha256"]}`.', '']
    (RESOURCES / 'SOURCES.md').write_text('\n'.join(lines), encoding='utf-8')


def check():
    metadata = json.loads((RESOURCES / 'sources.json').read_text(encoding='utf-8'))
    assert digest(DESIGN.read_bytes()) == metadata['design_sha256'], 'HTML alterado'
    required = {'Images/WelcomeCapybara.png', 'Images/OnsenWallpaper.png'} | {
        f'Fonts/{name}' for name in FONTS} | {f'Fonts/Figtree-{style}.ttf' for style in STATIC_FONTS}
    assert set(metadata['files']) == required, 'Manifesto de recursos US1 incompleto'
    sources = (RESOURCES / 'SOURCES.md').read_text(encoding='utf-8')
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
    print('US1: imagens, fontes, licenças e hashes conferidos. US2 e ícone ainda fora deste estágio.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Somente leitura, sem rede')
    args = parser.parse_args()
    if not args.check:
        prepare()
    check()
