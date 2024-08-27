; Define the color permutations
;Blue = 32;Green = 48;Pink=13;Red=40;Yellow=14
color1 DB 32,48,13,40,14
color2 DB 32,48,13,14,40
color3 DB 32,48,40,13,14
color4 DB 32,48,40,14,13
color5 DB 32,48,14,13,40
color6 DB 32,48,14,40,13
color7 DB 32,13,48,40,14
color8 DB 32,13,48,14,40
color9 DB 32,13,40,48,14
color10 DB 32,13,40,14,48
color11 DB 32,13,14,48,40
color12 DB 32,13,14,40,48
color13 DB 32,40,48,13,14
color14 DB 32,40,48,14,13
color15 DB 32,40,13,48,14
color16 DB 32,40,13,14,48
color17 DB 32,40,14,48,13
color18 DB 32,40,14,13,48
color19 DB 32,14,48,13,40
color20 DB 32,14,48,40,13
color21 DB 32,14,13,48,40
color22 DB 32,14,13,40,48
color23 DB 32,14,40,48,13
color24 DB 32,14,40,13,48
color25 DB 48,32,13,40,14
color26 DB 48,32,13,14,40
color27 DB 48,32,40,13,14
color28 DB 48,32,40,14,13
color29 DB 48,32,14,13,40
color30 DB 48,32,14,40,13
color31 DB 48,13,32,40,14
color32 DB 48,13,32,14,40
color33 DB 48,13,40,32,14
color34 DB 48,13,40,14,32
color35 DB 48,13,14,32,40
color36 DB 48,13,14,40,32
color37 DB 48,40,32,13,14
color38 DB 48,40,32,14,13
color39 DB 48,40,13,32,14
color40 DB 48,40,13,14,32
color41 DB 48,40,14,32,13
color42 DB 48,40,14,13,32
color43 DB 48,14,32,13,40
color44 DB 48,14,32,40,13
color45 DB 48,14,13,32,40
color46 DB 48,14,13,40,32
color47 DB 48,14,40,32,13
color48 DB 48,14,40,13,32
color49 DB 13,32,48,40,14
color50 DB 13,32,48,14,40
color51 DB 13,32,40,48,14
color52 DB 13,32,40,14,48
color53 DB 13,32,14,48,40
color54 DB 13,32,14,40,48
color55 DB 13,48,32,40,14
color56 DB 13,48,32,14,40
color57 DB 13,48,40,32,14
color58 DB 13,48,40,14,32
color59 DB 13,48,14,32,40
color60 DB 13,48,14,40,32
color61 DB 13,40,32,48,14
color62 DB 13,40,32,14,48
color63 DB 13,40,48,32,14
color64 DB 13,40,48,14,32
color65 DB 13,40,14,32,48
color66 DB 13,40,14,48,32
color67 DB 13,14,32,48,40
color68 DB 13,14,32,40,48
color69 DB 13,14,48,32,40
color70 DB 13,14,48,40,32
color71 DB 13,14,40,32,48
color72 DB 13,14,40,48,32
color73 DB 40,32,48,13,14
color74 DB 40,32,48,14,13
color75 DB 40,32,13,48,14
color76 DB 40,32,13,14,48
color77 DB 40,32,14,48,13
color78 DB 40,32,14,13,48
color79 DB 40,48,32,13,14
color80 DB 40,48,32,14,13
color81 DB 40,48,13,32,14
color82 DB 40,48,13,14,32
color83 DB 40,48,14,32,13
color84 DB 40,48,14,13,32
color85 DB 40,13,32,48,14
color86 DB 40,13,32,14,48
color87 DB 40,13,48,32,14
color88 DB 40,13,48,14,32
color89 DB 40,13,14,32,48
color90 DB 40,13,14,48,32
color91 DB 40,14,32,48,13
color92 DB 40,14,32,13,48
color93 DB 40,14,48,32,13
color94 DB 40,14,48,13,32
color95 DB 40,14,13,32,48
color96 DB 40,14,13,48,32
color97 DB 14,32,48,13,40
color98 DB 14,32,48,40,13
color99 DB 14,32,13,48,40
color100 DB 14,32,13,40,48
color101 DB 14,32,40,48,13
color102 DB 14,32,40,13,48
color103 DB 14,48,32,13,40
color104 DB 14,48,32,40,13
color105 DB 14,48,13,32,40
color106 DB 14,48,13,40,32
color107 DB 14,48,40,32,13
color108 DB 14,48,40,13,32
color109 DB 14,13,32,48,40
color110 DB 14,13,32,40,48
color111 DB 14,13,48,32,40
color112 DB 14,13,48,40,32
color113 DB 14,13,40,32,48
color114 DB 14,13,40,48,32
color115 DB 14,40,32,48,13
color116 DB 14,40,32,13,48
color117 DB 14,40,48,32,13
color118 DB 14,40,48,13,32
color119 DB 14,40,13,32,48
color120 DB 14,40,13,48,32


; Define the DW array to store the addresses of the color permutations
color_addresses DW offset color1, offset color2, offset color3, offset color4, offset color5
                DW offset color6, offset color7, offset color8, offset color9, offset color10
                DW offset color11, offset color12, offset color13, offset color14, offset color15
                DW offset color16, offset color17, offset color18, offset color19, offset color20
                DW offset color21, offset color22, offset color23, offset color24, offset color25
                DW offset color26, offset color27, offset color28, offset color29, offset color30
                DW offset color31, offset color32, offset color33, offset color34, offset color35
                DW offset color36, offset color37, offset color38, offset color39, offset color40
                DW offset color41, offset color42, offset color43, offset color44, offset color45
                DW offset color46, offset color47, offset color48, offset color49, offset color50
                DW offset color51, offset color52, offset color53, offset color54, offset color55
                DW offset color56, offset color57, offset color58, offset color59, offset color60
                DW offset color61, offset color62, offset color63, offset color64, offset color65
                DW offset color66, offset color67, offset color68, offset color69, offset color70
                DW offset color71, offset color72, offset color73, offset color74, offset color75
                DW offset color76, offset color77, offset color78, offset color79, offset color80
                DW offset color81, offset color82, offset color83, offset color84, offset color85
                DW offset color86, offset color87, offset color88, offset color89, offset color90
                DW offset color91, offset color92, offset color93, offset color94, offset color95
                DW offset color96, offset color97, offset color98, offset color99, offset color100
                DW offset color101, offset color102, offset color103, offset color104, offset color105
                DW offset color106, offset color107, offset color108, offset color109, offset color110
                DW offset color111, offset color112, offset color113, offset color114, offset color115
                DW offset color116, offset color117, offset color118, offset color119, offset color120


bubble_grid DB 280 DUP(0) ; 20 columns * 14 rows