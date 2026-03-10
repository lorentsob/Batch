require 'xcodeproj'

project_path = '/Users/lorentso/lievito-app/Levain.xcodeproj'
project = Xcodeproj::Project.open(project_path)

levain_target = project.targets.find { |t| t.name == 'Levain' }
tests_target = project.targets.find { |t| t.name == 'LevainTests' }

# Add knowledge.json
resources_group = project.main_group.children.find { |g| g.display_name == 'Levain' || g.path == 'Levain' }.children.find { |g| g.display_name == 'Resources' || g.path == 'Resources' }

if resources_group.nil?
  puts "Resources group not found, creating..."
  levain_group = project.main_group.children.find { |g| g.display_name == 'Levain' || g.path == 'Levain' }
  resources_group = levain_group.new_group('Resources', 'Resources')
end

json_ref = resources_group.files.find { |f| f.path == 'knowledge.json' }
if json_ref.nil?
  json_ref = resources_group.new_file('knowledge.json')
end

if levain_target.resources_build_phase.files_references.find { |fr| fr == json_ref }.nil?
  levain_target.resources_build_phase.add_file_reference(json_ref, true)
end

project.save
puts 'Project saved successfully'
