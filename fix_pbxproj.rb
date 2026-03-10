require 'xcodeproj'
project_path = 'Levain.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

group = project.main_group.find_subpath(File.join('Levain', 'Features', 'Bakes'), true)

['FormulaDetailView.swift', 'FormulaEditorView.swift'].each do |file_name|
  file_path = File.join('Levain', 'Features', 'Bakes', file_name)
  unless group.files.any? { |f| f.path == file_name }
    file_ref = group.new_reference(file_name)
    target.add_file_references([file_ref])
  end
end

project.save
