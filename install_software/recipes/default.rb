# Contains: Main recipe logic for installing and configuring software on Windows machines.
# Purpose: Installs Chocolatey, and uses it to install software like Notepad++ and VS Code, 
#          and downloads and installs Chrome and Firefox.

# Install Chocolatey
chocolatey_package 'chocolatey' do
  action :install
end

# Install software packages using Chocolatey
['notepadplusplus', 'vscode'].each do |package|
  chocolatey_package package do
    action :install
  end
end

# Ensure the packages directory exists
directory "#{ENV['USERPROFILE']}\\packages" do
  action :create
end

# Download Chrome installer
remote_file "#{ENV['USERPROFILE']}\\packages\\chrome_installer.exe" do
  source 'https://dl.google.com/chrome/install/latest/chrome_installer.exe'
  action :create
end

# Download Firefox installer
remote_file "#{ENV['USERPROFILE']}\\packages\\firefox_installer.exe" do
  source 'https://download.mozilla.org/?product=firefox-latest&os=win&lang=en-US'
  action :create
end

# Install Chrome
windows_package 'Google Chrome' do
  source "#{ENV['USERPROFILE']}\\packages\\chrome_installer.exe"
  action :install
end

# Install Firefox
windows_package 'Mozilla Firefox' do
  source "#{ENV['USERPROFILE']}\\packages\\firefox_installer.exe"
  action :install
end

