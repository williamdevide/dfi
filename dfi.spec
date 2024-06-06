# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['app.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=['pyodbc'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=['parameters', 'src/database/sql/avacorpConsultaAbastecimentosModelo2', 'src/database/sql/avacorpConsultaDocumentosEmitidos', 'src/database/sql/avacorpFiscalFinanceiroContabil', 'src/database/sql/avacorpFluxoCaixaFuturoModelo2', 'src/database/sql/avacorpFluxoCaixaRealizadoModelo2', 'src/database/sql/avacorpHistoricoGastosComManutencao', 'src/database/sql/avacorpNotificacaoMultaDeTransito', 'src/database/sql/avacorpPedidoColeta', 'src/database/sql/avacorpVeiculo', 'src/database/sql/commoditiesMerge'],
    noarchive=False,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='dfi',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
