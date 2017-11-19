
sources = [
    'Tranqil.vala',
    'TranqilWindow.vala',
    'TranBus.vala',
    tranqil_resources
]

executable ('com.github.nick92.tranqil',
            sources,
            dependencies: [glib, gtk, gstreamer],
            vala_args:['--target-glib=2.38', '--gresources=' + meson.source_root () + '/data/tranqil-resource.xml'],
            install: true
            )
