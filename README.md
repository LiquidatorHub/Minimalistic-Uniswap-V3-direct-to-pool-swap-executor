# Minimalistic-Uniswap-V3-direct-to-pool-swap-executor
- 🔒 **Callback secured** via `activePools` gating (no arbitrary callback execution)
- ⚡ Supports direct pool-level swaps (no router overhead)
- 🧠 Minimal gas design, ideal for MEV bots / liquidators
- 🧪 Can be used in flashloan/arb/liq strategies


*Parameters:   function swapdirecttopoolv3(address pool, bool zeroForOne) external 

address pool — the address of the Uniswap V3-style pool (must implement swap, token0, token1, slot0, etc.).

bool zeroForOne:
    -true: swap token0 → token1
    -false: swap token1 → token0
