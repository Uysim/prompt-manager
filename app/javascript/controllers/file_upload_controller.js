import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "fileList"]

  connect() {
    this.setupDragAndDrop()
    this.setupClearAll()
  }

  handleFiles(event) {
    const files = event.target.files
    this.displayFiles(files)
  }

  setupDragAndDrop() {
    const dropZone = this.element.querySelector('.border-dashed')
    
    dropZone.addEventListener('dragover', (e) => {
      e.preventDefault()
      dropZone.classList.add('border-blue-400', 'bg-blue-50')
      dropZone.classList.remove('border-gray-300', 'bg-gray-50')
    })

    dropZone.addEventListener('dragleave', (e) => {
      e.preventDefault()
      dropZone.classList.remove('border-blue-400', 'bg-blue-50')
      dropZone.classList.add('border-gray-300', 'bg-gray-50')
    })

    dropZone.addEventListener('drop', (e) => {
      e.preventDefault()
      dropZone.classList.remove('border-blue-400', 'bg-blue-50')
      dropZone.classList.add('border-gray-300', 'bg-gray-50')
      
      const files = e.dataTransfer.files
      this.inputTarget.files = files
      this.displayFiles(files)
    })
  }

  setupClearAll() {
    const clearButton = this.element.querySelector('#clear-files')
    if (clearButton) {
      clearButton.addEventListener('click', () => {
        this.clearAllFiles()
      })
    }
  }

  displayFiles(files) {
    if (files.length === 0) return

    const preview = this.element.querySelector('#file-preview')
    const fileList = this.element.querySelector('#file-list')
    
    preview.classList.remove('hidden')
    fileList.innerHTML = ''

    Array.from(files).forEach((file, index) => {
      const fileItem = document.createElement('div')
      fileItem.className = 'flex items-center justify-between p-3 bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition-shadow duration-200'
      
      fileItem.innerHTML = `
        <div class="flex items-center space-x-3">
          <div class="flex-shrink-0">
            <svg class="h-8 w-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-gray-900 truncate">${file.name}</p>
            <p class="text-xs text-gray-500">${this.formatFileSize(file.size)}</p>
          </div>
        </div>
        <button type="button" class="flex-shrink-0 text-red-600 hover:text-red-800 text-sm font-medium p-1 hover:bg-red-50 rounded transition-colors duration-200" onclick="this.closest('.flex').remove()">
          Remove
        </button>
      `
      
      fileList.appendChild(fileItem)
    })
  }

  clearAllFiles() {
    const fileList = this.element.querySelector('#file-list')
    const preview = this.element.querySelector('#file-preview')
    const input = this.element.querySelector('input[type="file"]')
    
    fileList.innerHTML = ''
    preview.classList.add('hidden')
    input.value = ''
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }
} 