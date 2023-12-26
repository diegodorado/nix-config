return {
  --disable flash
  { "folke/flash.nvim", enabled = false },
  --disable mini.pairs
  { "echasnovski/mini.pairs", enabled = false },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          -- disable fuzzy finder filter
          ["/"] = "none",
        },
      },
      filesystem = {
        window = {
          mappings = {
            -- disable fuzzy finder filter
            ["/"] = "none",
          },
        },
      },
    },
  },
}
