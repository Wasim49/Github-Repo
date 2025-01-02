directory 'C:/example_directory' do
    action :create         # Ensures the directory is created
  end


file 'C:/example_directory/example_file.txt' do
    content 'This is a test file created by Chef.'
    action :create  # Ensures the file is created
  end