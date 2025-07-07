// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

eagerLoadControllersFrom("controllers", application)

// import HelloController from "./hello_controller"
// application.register("hello", HelloController)

// import FileUploadController from "./file_upload_controller"
// application.register("file-upload", FileUploadController)
