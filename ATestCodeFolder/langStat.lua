--[[
/*************************************************************
* Date : 2013-05-04
* Author : FQS
* Desc : ����luapages�����еĽű��ļ���
		ͳ�Ƴ�langxx.lua�����ô���--��ɾ����ɾ�����ߵ����룬
		ͳ�Ƴ�langxx.lua��ȱʧ����--����ӣ����ķ���Ҫ��
**************************************************************/
]]

require'lfs'

-- ��ͳ�ƵĴ����ļ�·��
local langFiles = {
	"langen.lua",
	"langcn.lua"
}

-- �ڽű�ʹ�õĴ���ID
local usedLangs = {}

-- ͳ��luapages�ļ����½ű�ʹ�õĴ���
function statUsedLangs (scriptFile)
	-- �����ļ�ÿһ��
     for line in io.lines(scriptFile) do
		--print("line = " .. line )

		-- �������ø�ʽ &?xxx;
		 for langID in string.gmatch(line, "&?(%w+);") do
		   table.insert(usedLangs, langID)
		   --print("langID " .. langID .. " used in format &?xxx;")
		 end
		-- �������ø�ʽ lang.xxx
		 for langID in string.gmatch(line, "lang%.(%w+)") do
		   table.insert(usedLangs, langID)
		   --print("langID " .. langID .. " used in format lang.xxx")
		 end
     end
end

-- ͳ��luapages�ļ��м������ļ���
function statDirectory(dir)
	for subItem in lfs.dir(dir) do
		if subItem ~= "." and subItem ~= ".." then
			local f = dir.."\\"..subItem

			--print ("\t=> "..f.." <=")

			local attr = lfs.attributes (f)
			--print ("attr.mode="..attr.mode)
			--assert (type(attr) == "table")

			if attr.mode == "directory" then
				statDirectory(f)
			else
				statUsedLangs (f)
			end
		end
	end
end

-- ͳ�ƴ���
statDirectory(".\\luapages")

print("All used langs in Scripts is below:")
for k,v in pairs(usedLangs) do
	print("usedLang"..k.."="..v);
end

-- ��langxx.lua��ͳ�Ƴ������ȱʧ����
for k,v in pairs(langFiles) do
	-- ���ش����ļ�
	local langPath = ".\\luapages\\config\\"
	local langFile = langPath..v;
	dofile(langFile)

	-- ��ͳ�ƽ��д�뵽langxx.lua��Ӧ�ļ�langxx_stat.txt
	local statFile = io.open(langFile .."_stat.txt", "w+")
	statFile:write("##stat reslut at time(" .. os.date() .. ")\n")

	-- ͳ���������
	local langsDel = {}
	for langID, langVal in pairs(lang) do
		local usedflag = "NO";
		for _,usedLang in pairs(usedLangs) do
			if usedLang == langID then
				usedflag = "YES";
			end
		end

		if usedflag == "NO" then
			table.insert(langsDel, langID);
		end
	end

	print("All no used langs in langxx.lua is below:")
	statFile:write("\n--All no used langs in langxx.lua is below:\n")
	for k,v in pairs(langsDel) do
		print("langDel"..k.."="..v);
		statFile:write("langDel"..k.."="..v.."\n");
	end

	-- ͳ��ȱʧ����
	local langsMiss = {}
	for _, usedLang in pairs(usedLangs) do
		local existflag = "NO"
		if lang[usedLang] then
			existflag = "YES"
		end

		if existflag == "NO" then
			table.insert(langsMiss, usedLang);
		end
	end

	print("All missed langs in langxx.lua is below:")
	statFile:write("\n--All missed langs in langxx.lua is below:\n")
	for k,v in pairs(langsMiss) do
		print("langDel"..k.."="..v);
		statFile:write("langMiss"..k.."="..v.."\n");
	end

	io.close(statFile)
end

