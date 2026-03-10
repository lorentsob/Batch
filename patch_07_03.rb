require 'xcodeproj'

project_path = '/Users/lorentso/lievito-app/Levain.xcodeproj'
project = Xcodeproj::Project.open(project_path)

tests_target = project.targets.find { |t| t.name == 'LevainTests' }

def add_file_to_group(project, group_path, filename)
  components = group_path.split('/')
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

lib_tests_ref = add_file_to_group(project, 'LevainTests', 'KnowledgeLibraryTests.swift')
unless tests_target.source_build_phase.files_references.include?(lib_tests_ref)
  tests_target.source_build_phase.add_file_reference(lib_tests_ref, true)
end

project.save
puts 'Project saved successfully'
