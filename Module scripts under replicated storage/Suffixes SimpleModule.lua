local Suffixes = {"K", "M", "B", "T",
	"QD", "QN", "SX", "SP", "Oc", "No", "Dec",
	"UnD", "DD", "TD", "QdD", "QND", "SXD", 
	"SPD", "OD", "ND", "VN", "UVN", "DUOVN",
	"TREVN","QVN","SXVN","SPVN","OCVN","NOVN",
	"TRI","UTri","DuoTri","TreTri","QdTri","QnTri",
	"SxTri","SpTri","OcTri","NoTri","Qua","UQua",
	"DQua","TQua","QdQua","QnQua","QnQua","SxQua",
	"SpQua","OcQua","NoQua","Qnt","UQnt","DQnt",
	"TQnt","QdQnt","QnQnt","SxQnt","SpQnt","OcQnt",
	"NoQnt","Sxa","USxa","DSxa","TSxa","QdSxa","QnSxa",
	"SxSxa","SpSxa","OcSxa","NoSxa","Spt","USpt","DSpt",
	"TSpt","QdSpt","QnSpt","SxSpt","SpSpt","OcSpt","NoSpt",
	"Oct","UOct","DOct","TOct","QdOct","QnOct","SxOct","SpOct",
	"OcOct","NoOct","Non","UNon","DNon","TNon","QdNon","QnNon",
	"SxNon","SpNon","OcNon","NoNon","Ce","UCe","DCe"
}
_G.Suffixes = Suffixes
function ConvertSuffix(Num: number, Suffix: string)
	local Str = table.find(_G.Suffixes, Suffix)
	if not Str then
		return Num
	end
	return Num * 1000 ^ (Str)
end
_G.ConvertSuffix = ConvertSuffix
return Suffixes