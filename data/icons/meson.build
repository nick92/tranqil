sizes = ['32x32', '48x48' , '64x64', '128x128']
themedir = get_option('datadir') + '/icons/hicolor/'

foreach size: sizes
    install_data(size + '/tranquil.svg', install_dir: themedir + size + '/apps/')
endforeach

