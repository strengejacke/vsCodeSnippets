#' @export
update_R_packages <- function() {
  old_packages <- old.packages()
  user_packages <- grepl(
    paste0("^", dirname(path.expand("~"))),
    old_packages[, "LibPath"]
  )

  if (any(user_packages)) {
    needs_update <- names(old_packages[, "LibPath"][user_packages])
    install.packages(needs_update)
  }
}
