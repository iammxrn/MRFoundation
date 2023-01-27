#
# Copyright (c) 2022 Roman Mogutnov (Mix-Roman)
#

Pod::Spec.new do |s|
  s.name = "MRFoundation"
  s.version = "1.3.0"
  s.summary = "A library to complement the Swift Standard Library."

  s.homepage = "https://github.com/djmixroman/MRFoundation"
  s.license = { :type => "MIT", :file => "LICENSE.md" }
  s.source = { :git => "https://github.com/djmixroman/MRFoundation.git", :tag => s.version.to_s }
  s.authors = { "Roman Mogutnov" => "https://twitter.com/iammxrn" }
  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "11.0"
  s.swift_versions = ["5.0"]

  s.source_files = "MRFoundation/Sources/**/*"

  s.frameworks = "Foundation"
end
