\name{vigiar_client}
\alias{vigiar_client}
\title{Create a VIGIAR Power BI client}
\usage{
vigiar_client(timeout = 30, max_retries = 3)
}
\arguments{
  \item{timeout}{Seconds before HTTP timeout.}
  \item{max_retries}{Maximum retry attempts on transient failures.}
}
\value{
  An object of class \code{"vigiar_client"}.
}
\description{
  Creates an explicit session object for communicating with the
  VIGIAR Power BI dashboard.  All state is self-contained in the
  returned object (no global variables).
}
\examples{
\dontrun{
client <- vigiar_client()
print(client)
}
}
