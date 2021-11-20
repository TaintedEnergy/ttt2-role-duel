CreateConVar("ttt2_duelist_is_public", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt2_duelist_prevent_win", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt2_duelist_immunity", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt2_duelist_victory_regenerate", 200, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})

hook.Add("TTTUlxDynamicRCVars", "ttt2_ulx_dynamic_leech_convars", function(tbl)
  tbl[ROLE_DUELIST] = tbl[ROLE_DUELIST] or {}

  table.insert(tbl[ROLE_DUELIST], {
      cvar = "ttt2_duelist_is_public",
      checkbox = true,
      desc = "ttt2_duelist_is_public (def. 0)"
  })

  table.insert(tbl[ROLE_DUELIST], {
    cvar = "ttt2_duelist_prevent_win",
    checkbox = true,
    desc = "ttt2_duelist_prevent_win (def. 1)"
  })

  table.insert(tbl[ROLE_DUELIST], {
    cvar = "ttt2_duelist_immunity",
    checkbox = true,
    desc = "ttt2_duelist_immunity (def. 0)"
  })

  table.insert(tbl[ROLE_DUELIST], {
      cvar = "ttt2_duelist_victory_regenerate",
      slider = true,
      min = 0,
      max = 1000,
      decimal = 0,
      desc = "ttt2_duelist_victory_regenerate (def. 100)"
  })
end)
