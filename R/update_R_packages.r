update_R_packages <- function(unload_namespace = TRUE, use_pak = FALSE) {
  if (isTRUE(unload_namespace)) {
    loaded_pkgs <- loadedNamespaces()
    # fmt: skip
    base_pkgs <- c(
      "base", "compiler", "datasets", "graphics", "grDevices", "grid",
      "methods", "parallel", "splines", "stats", "stats4", "tools", "tcltk",
      "utils"
    )
    needs_unload <- setdiff(loaded_pkgs, base_pkgs)
    could_not_unload <- c()
    if (length(needs_unload)) {
      for (p in needs_unload) {
        tryCatch(unloadNamespace(p), error = function(e) {
          # remember packages that could not be unloaded.
          could_not_unload <- c(could_not_unload, p)
        })
      }
    }
  }

  # check installed and on CRAN available packages
  installed_packages <- utils::installed.packages()
  available_packages <- utils::available.packages()

  # remove packages that are not installed by user - these are shipped with
  # R and annot be updated
  user_packages <- grepl(
    paste0("^", dirname(path.expand("~"))),
    installed_packages[, "LibPath"]
  )

  # check if any user installed packages are available
  if (any(user_packages)) {
    installed_packages <- installed_packages[user_packages, ]

    # make sure we have same length of installed and available packages
    # E.g. if user installed packages from GitHub that are not on CRAN,
    # this will result in "mismatch"
    can_update <- intersect(
      available_packages[, "Package"],
      installed_packages[, "Package"]
    )

    available_packages <- available_packages[
      available_packages[, "Package"] %in% can_update,
    ]
    installed_packages <- installed_packages[
      installed_packages[, "Package"] %in% can_update,
    ]

    # check for old package versions
    needs_update <- installed_packages[
      which(
        installed_packages[, "Version"] < available_packages[, "Version"]
      ),
      "Package"
    ]

    # skip packages that could not be unloaded...
    if (length(could_not_unload)) {
      msg <- paste0(
        "\nFollowing package",
        ifelse(length(could_not_unload) > 1, "s have", "has"),
        " updates but could not be unloaded: ",
        toString(could_not_unload)
      )
      message(msg, " Please try installing them using pure R.\n")
      needs_update <- setdiff(needs_update, could_not_unload)
    }
    if (length(needs_update)) {
      msg <- paste0(
        "\nInstalling ",
        length(needs_update),
        " package",
        ifelse(length(needs_update) > 1, "s", ""),
        ": ",
        toString(needs_update),
        "\n\n"
      )
      message(msg)
      if (use_pak) {
        pak::pkg_install(needs_update)
      } else {
        utils::install.packages(needs_update)
      }
    }
  } else {
    message("\nAll packages are up to date!\n")
  }
}
