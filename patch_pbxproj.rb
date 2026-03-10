require 'xcodeproj'

project_path = '/Users/lorentso/lievito-app/Levain.xcodeproj'
project = Xcodeproj::Project.open(project_path)

levain_target = project.targets.find { |t| t.name == 'Levain' }
tests_target = project.targets.find { |t| t.name == 'LevainTests' }

# File paths to add to Levain target
levain_files = [
  'Levain/Features/Starter/StarterCardView.swift',
  'Levain/Features/Starter/StarterDetailHeaderView.swift',
  'Levain/Features/Starter/StarterDetailView.swift',
  'Levain/Features/Starter/StarterEditorView.swift',
  'Levain/Features/Starter/RefreshLogView.swift',
  'Levain/Features/Starter/RefreshHistoryRow.swift',
  'Levain/Services/StarterReminderPlanner.swift'
]

# File paths to add to LevainTests target
tests_files = [
  'LevainTests/StarterTests.swift',
  'LevainTests/StarterReminderPlannerTests.swift'
]

# Helper to find or create group for path
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
  
  # Check if file already exists in group
  file_ref = group.files.find { |f| f.path == filename }
  if file_ref.nil?
    file_ref = group.new_file(filename)
  end
  file_ref
end

levain_files.each do |path|
  file_ref = add_file_to_group(project, path)
  levain_target.source_build_phase.add_file_reference(file_ref, true)
end

tests_files.each do |path|
  file_ref = add_file_to_group(project, path)
  tests_target.source_build_phase.add_file_reference(file_ref, true)
end

project.save
puts 'Project saved successfully'
