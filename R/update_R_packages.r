#' @export
update_R_packages <- function() {
  old_packages <- utils::old.packages()
  user_packages <- grepl(
    paste0("^", dirname(path.expand("~"))),
    old_packages[, "LibPath"]
  )

  if (any(user_packages)) {
    needs_update <- names(old_packages[, "LibPath"][user_packages])
    msg <- paste0(
      "\nInstalling ", length(needs_update), " package",
      ifelse(length(needs_update) > 1, "s", ""), ": ",
      datawizard::text_concatenate(needs_update), "\n\n"
    )
    insight::print_color(msg, "blue")
    utils::install.packages(needs_update)
  } else {
    insight::print_color("\nAll packages are up to date!\n\n", "green")
  }
}
