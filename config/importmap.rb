# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@rails/activestorage", to: "@rails--activestorage.js" # @8.1.300
pin "cropperjs" # @1.6.2
# Quill is loaded as a global <script> tag from CDN (not importmap) because
# the jspm.io ESM build uses relative sub-module imports that aren't vendored.
