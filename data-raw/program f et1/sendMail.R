install.packages("sendmailR")
library(sendmailR)

from <- "lindmark.goran@gmail.com"
to <- "lindmark.goran@gmail.com"
subject <- "Mail test from R"
body <- "This is the body of the email."


email <- mime_part(body)
email[["headers"]][["Subject"]] <- subject


sendmail(from, to, email, control = list(smtpServer = "smtp.gmail.com"))
sendmail(from ="from@example.org",
         to ="to1@example.org",
         subject = "File attachment",
         msg=c(
           mime_part("Hello everyone,\n here is the newest report.\n Bye"),
           mime_part(htmlout, name = "report.html")),
         engine = "debug")

install.packages("gmailr", repos="http://cran.r-project.org")
library(gmailr)
