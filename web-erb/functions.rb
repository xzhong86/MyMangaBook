
require 'yaml'

def load_books()
  Dir.glob($env.root + '/book-*').sort.map do |dir|
    info = File.join(dir, 'info.yaml')
    if File.exist? info
      info = YAML.load(IO.read(info))
      info = OpenStruct.new info
      info.dir = File.basename(dir)
      info
    else
      nil
    end
  end.compact
end
