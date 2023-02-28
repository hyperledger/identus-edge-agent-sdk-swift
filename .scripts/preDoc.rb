require 'json'

# Read the string-replacements from the .jazzy.json file
jazzy_conf = JSON.parse(File.read('.jazzy.json'))
transforms = jazzy_conf['string-replacements']

# Loop through all .md files in the Documentation directory
Dir.glob('Documentation/*.md').each do |file|
  # Read the contents of the file
  contents = File.read(file)

  # Apply all replacements to the contents of the file
  if transforms
    transforms.each_pair do |key, value|
      contents = contents.gsub(key, value)
    end
  end

  # Replace <doc:AnythingAndSomething> with a link to anythingandsomething.html
  contents = contents.gsub(/<doc:([\w\s]+)>/) do |match|
    name = match.gsub('<doc:', '').gsub('>', '').gsub(/(.)([A-Z])/,'\1 \2')
    link = name.downcase.gsub(' ', '') + '.html'
    "[#{name}](#{link})"
  end

  # Write the updated contents back to the file
  File.write(file, contents)
end
