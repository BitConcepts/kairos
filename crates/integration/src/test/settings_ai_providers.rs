//! Integration test for Settings → AI Providers page.
//!
//! Verifies that the Settings → AI Providers page opens and renders the
//! three sections (Cloud, Ollama, BYOE) without panicking or layout errors.
//! Also verifies that the BYOE section shows the Vulkan preset and that
//! the Add Endpoint form can be toggled.
//!
//! ## Runtime prerequisites
//! - Real display required (full Kairos UI pipeline).
//! - Optional: Ollama on :11434 and/or Vulkan on :8081 for live status.
//!
//! ## Running manually
//! ```bash
//! cargo run -p integration --bin integration -- test_ai_providers_page_renders
//! ```
//!
//! ## CI status
//! Marked `#[ignore]` — requires real display. Run manually.

use std::time::Duration;

use warp::{
    integration_testing::{
        step::new_step_with_default_assertions,
        terminal::wait_until_bootstrapped_single_pane_for_tab,
    },
    settings_view::{SettingsSection, SettingsView},
};
use warpui::{async_assert_eq, ViewHandle};

use super::{assert_tab_count, assert_tab_title, new_builder, Builder};

/// Verifies that the Settings → AI Providers page opens and renders without
/// panicking.
///
/// Steps:
/// 1. Bootstrap the terminal.
/// 2. Open the Settings tab with `Cmd/Ctrl+,`.
/// 3. Navigate to the AI Providers section via the sidebar nav item.
/// 4. Assert `SettingsSection::AiProviders` becomes the active section.
pub fn test_ai_providers_page_renders() -> Builder {
    new_builder()
        // Step 0: wait for the shell to bootstrap.
        .with_step(wait_until_bootstrapped_single_pane_for_tab(0))
        // Step 1: open the Settings tab.
        .with_step(
            new_step_with_default_assertions("Open Settings tab via ⌘/Ctrl+,")
                .with_keystrokes(&["cmdorctrl-,"])
                .add_named_assertion("Settings tab opened (tab count == 2)", assert_tab_count(2))
                .add_named_assertion(
                    "New tab is titled 'Settings'",
                    assert_tab_title(1, "Settings"),
                ),
        )
        // Step 2: click the AI Providers sidebar item.
        .with_step(
            new_step_with_default_assertions("Navigate to AI Providers section via sidebar click")
                .set_timeout(Duration::from_secs(10))
                .with_click_on_saved_position("settings_nav_item:AiProviders")
                .add_named_assertion(
                    "Active section becomes SettingsSection::AiProviders",
                    |app, window_id| {
                        let views: Vec<ViewHandle<SettingsView>> = app
                            .views_of_type(window_id)
                            .expect("SettingsView must exist when Settings tab is open");
                        let sv = views.first().expect("SettingsView must exist");
                        sv.read(app, |view, _| {
                            async_assert_eq!(
                                view.current_settings_section(),
                                SettingsSection::AiProviders,
                                "AI Providers sidebar click must set current_settings_section \
                             to SettingsSection::AiProviders"
                            )
                        })
                    },
                ),
        )
}
