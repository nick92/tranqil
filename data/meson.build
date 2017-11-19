gnome = import ('gnome')

tranqil_resources = gnome.compile_resources ('tranqil_resources', 'tranqil-resource.xml', source_dir: '.', c_name: 'tranqil')

install_data('com.github.nick92.tranqil.desktop',
    install_dir : join_paths('share', 'applications'))

install_data('com.github.nick92.tranqil.gschema.xml',
    install_dir : join_paths('share', 'glib-2.0', 'schemas'))

install_data('com.github.nick92.tranqil.appdata.xml',
    install_dir : join_paths('share', 'metainfo'))

meson.add_install_script('install_schema.py')

subdir('icons')
