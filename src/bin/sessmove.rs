// SPDX-License-Identifier: GPL-3.0-or-later
//! sessmove: move a project directory and rewrite every AI agent's local
//! session/config references to it, in one step (agentpath mv).
fn main() -> anyhow::Result<()> {
    sessmove::cli::run_mv()
}
