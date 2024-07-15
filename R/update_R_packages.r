#' @export
update_R_packages <- function(unload_namespace = TRUE) {
  if (isTRUE(unload_namespace)) {
    loaded_pkgs <- loadedNamespaces()
    base_pkgs <- c(
      "base", "compiler", "datasets", "graphics", "grDevices", "grid",
      "methods", "parallel", "splines", "stats", "stats4", "tools", "tcltk",
      "utils"
    )
    needs_unload <- setdiff(loaded_pkgs, base_pkgs)
    could_not_unload <- c()
    if (length(needs_unload)) {
      for (p in needs_unload) {
        tryCatch(unloadNamespace(p),
                 error = function(e) {
                   # remember packages that could not be unloaded.
                   could_not_unload <- c(could_not_unload, p)
                 })
      }
    }
  }

  old_packages <- utils::old.packages()
  user_packages <- grepl(
    paste0("^", dirname(path.expand("~"))),
    old_packages[, "LibPath"]
  )

  if (any(user_packages)) {
    needs_update <- old_packages[, "Package"][user_packages]
    # skip packages that could not be unloaded...
    if (length(could_not_unload)) {
      msg <- paste0(
        "\nFollowing package", ifelse(length(could_not_unload) > 1, "s have", "has"),
        " updates but could not be unloaded: ",
        toString(could_not_unload)
      )
      message(msg, " Please try installing them using pure R.\n")
      needs_update <- setdiff(needs_update, could_not_unload)
    }
    if (length(needs_update)) {
      msg <- paste0(
        "\nInstalling ", length(needs_update), " package",
        ifelse(length(needs_update) > 1, "s", ""), ": ",
        toString(needs_update), "\n\n"
      )
      message(msg)
      pak::pkg_install(needs_update)
    }
  } else {
    message("\nAll packages are up to date!\n")
  }
}
