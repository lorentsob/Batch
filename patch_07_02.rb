require 'xcodeproj'

project_path = '/Users/lorentso/lievito-app/Levain.xcodeproj'
project = Xcodeproj::Project.open(project_path)

levain_target = project.targets.find { |t| t.name == 'Levain' }

new_files = [
  'Levain/Features/Knowledge/KnowledgeCategoryPillView.swift',
  'Levain/Features/Knowledge/KnowledgeRowView.swift',
  'Levain/Features/Knowledge/KnowledgeDetailView.swift'
]

def add_file_to_group(project, path)
  components = path.split('/')
  filename = components.pop
  
  group = project.main_group
  components.each do |c|
    child = group.children.find { |g| g.display_name == c || g.path == c }
    if child.nil?
      child = group.new_group(c, c)
    end
    group = child
  end
  
  file_ref = group.files.find { |f| f.path == filename }
  if file_ref.nil?
    file_ref = group.new_file(filename)
  end
  file_ref
end

new_files.each do |path|
  file_ref = add_file_to_group(project, path)
  unless levain_target.source_build_phase.files_references.include?(file_ref)
    levain_target.source_build_phase.add_file_reference(file_ref, true)
  end
end

project.save
puts 'Project saved successfully'
