project ('com.github.nick92.tranqil', ['vala', 'c'])

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

glib = dependency ('glib-2.0')
gtk = dependency ('gtk+-3.0')
gstreamer = dependency('gstreamer-1.0')
cairo = dependency('cairo')

subdir ('data')
subdir ('src')
