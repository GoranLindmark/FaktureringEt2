library(officer)
library(rmarkdown)

  # Load the Word document
  doc <- read_docx("data-raw/fakturainnehåll .docx")

  # Save the document as a temporary markdown file
  temp_md <- tempfile(fileext = ".docx")
  print(doc, target = temp_md)

  currentFile <- "data-raw/fakturainnehåll .docx"
  newFile <- "data/fakturainnehåll .docx"
  file.copy(from=currentFile, to=newFile,
            overwrite = TRUE, recursive = FALSE,
            copy.mode = TRUE)

  # Convert the markdown file to PDF
  output_pdf <- "data/document.pdf"
  render(currentFile, output_format = "pdf_document", output_file = output_pdf)


  # Remove the temporary markdown file
  unlink(temp_md)


