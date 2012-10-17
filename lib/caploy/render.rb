require 'erubis'

def render_erb_template(template_path, vars={})
  raise "file '#{template_path}' not exists" unless File.exist? template_path

  template = File.open(template_path, 'r').read
  Erubis::Eruby.new(template).result(vars)
end
