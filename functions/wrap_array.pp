function app_modeling::wrap_array (
  $maybe_array,
) {
  is_array($maybe_array) ? {
    true => $maybe_array,
    false => [$maybe_array],
  }
}
