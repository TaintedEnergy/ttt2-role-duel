L = LANG.GetLanguageTableReference("en")

L[DUELIST.name] = "Duelist"
L["info_popup_" .. DUELIST.name] = [[You are a Duelist! Kill the other Duelist to become your true role!]]
L["body_found_" .. DUELIST.abbr] = "They were a Duelist!"
L["search_role_" .. DUELIST.abbr] = "This person was a Duelist!"
L["target_" .. DUELIST.name] = "Duelist"
L["ttt2_desc_" .. DUELIST.name] = [[Duelist is a neutral killing role that needs to kill the other Duelist in the game to become the role assigned to the winning Duelist.]]

L["label_duelist_is_public"] = "Is Duelist public to all players"
L["label_duelist_prevent_win"] = "Do Duellists prevent a win from occuring if still alive"
L["label_duelist_immunity"] = "Duellists can only hurt and be hurt by other duellists"
L["label_duelist_prize_type"] = "Prize Role: (0)=Previous Duelist Role (1)=Random Role (2)=Undecided Role"
L["label_duelist_victory_regenerate"] = "How much health Duellists can get up to when victorious"