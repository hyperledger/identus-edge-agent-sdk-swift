File.open('docs/index.html', 'r+') do |file|
  content = file.read
  content.gsub!('Castor Reference', 'Atala PRISM SDK Reference')
  content.gsub!('Castor Docs', 'Atala PRISM SDK Docs')
  file.rewind
  file.write(content)
end
