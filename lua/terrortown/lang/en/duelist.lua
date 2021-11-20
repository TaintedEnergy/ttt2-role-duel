L = LANG.GetLanguageTableReference("en")

L[DUELIST.name] = "Duelist"
L["info_popup_" .. DUELIST.name] = [[You are a Duelist! Kill the other Duelist to become your true role!]]
L["body_found_" .. DUELIST.abbr] = "They were a Duelist!"
L["search_role_" .. DUELIST.abbr] = "This person was a Duelist!"
L["target_" .. DUELIST.name] = "Duelist"
L["ttt2_desc_" .. DUELIST.name] = [[Duelist is a neutral killing role that needs to kill the other Duelist in the game to become the role assigned to the winning Duelist.]]

L["label_duelist_is_public"] = "Is Duelist public to all players"
L["label_duelist_prevent_win"] = "Do Duelists prevent a win from occuring if still alive"
L["label_duelist_immunity"] = "Duelists can only hurt and be hurt by other duelists"
L["label_duelist_victory_regenerate"] = "How much health Duelists can get up to when victorious"