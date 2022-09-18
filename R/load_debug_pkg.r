# This functions loads the current package and refreshed break-points in
# VS Code. Use this to debug packages with breakpoint

#' @export
load_debug_pkg <- function() {
  ret <- pkgload::load_all()
  exports <- as.environment(paste0("package:", environmentName(ret$env)))
  vscDebugger::.vsc.refreshBreakpoints(list(ret$env, exports))
}
