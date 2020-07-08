Pod::Spec.new do |s|
  s.name             = "TFBubbleItUp"
  s.version          = "2.2.0"
  s.summary          = "Text field with bubbles and ability of validation"

  s.description      = <<-DESC
                        Custom view for writing tags, contacts and etc. with validation.
                       DESC

  s.homepage         = "https://github.com/futuredapp/TFBubbleItUp"
  s.screenshots     = "https://raw.githubusercontent.com/futuredapp/TFBubbleItUp/master/preview.gif"
  s.license          = 'MIT'
  s.author           = { "Ales Kocur" => "aleskocur@icloud.com" }
  s.source           = { :git => "https://github.com/futuredapp/TFBubbleItUp.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Futuredapps'

  s.platform     = :ios, '10.0'
  s.requires_arc = true
  s.swift_version = '5.0'

  s.source_files = 'Sources/TFBubbleItUp/*'
end
