program NesToy12;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  FileCtrl,
  NameCvt in 'Units\NameCvt.pas',
  Utility in 'Units\Utility.pas',
  Crt32 in 'Units\Crt32.pas',
  Sorting in 'Units\Sorting.pas',
  NesUnit in 'Units\NesUnit.pas',
  NESCmdLine in 'Units\NESCmdLine.pas',
  NesCfgFile in 'Units\NesCfgFile.pas',
  IPSPatch in 'Units\IPSPatch.pas';

const
  dirlimit=6;
  maxdbasesize=4000;
  maxdirsize=4000;
  maxpathnames=200;
  dbasefile='nesdbase.dat';
  outputfile='output.txt';
  version='1.2';
  private_build=false;
  title='NesToy';
  webpage='http://romcollectors.cjb.net';
  logfile:string='nestoy.log';
  badchr:string=' (Bad CHR';

var
  NesDBase:array[1..maxdbasesize] of record
                                       csum:string[8];
                                       flag:boolean;
                                       resize:integer;
                                       name:shortstring;
                                       header:string[8];
                                       country:shortstring;
                                     end;
  PrgCSumArray:array[1..maxdbasesize] of string;
  dirarray:array[1..maxdirsize] of string;
  FCPrg,FCChr:array[1..400] of byte;
  dirpaths:PathArray;
  NesCL:TNesCmdLine;
  dbasecount,FCCount:integer;
  cpath,progpath:string;
  flagrom,wrotelog:boolean;

procedure pause;
begin
  write('Press any key to continue');
  readkey;
  gotoxy(1,wherey);
  clreol;
end;

procedure getsortdir(code:string;var sortdir:string;var sortunl:boolean);
var
  tempdir:string;
begin
  tempdir:='';
  sortunl:=false;
  if code=empty then begin tempdir:=dir_other; sortunl:=false; end;
  if code[7]='1' then begin tempdir:=dir_pirate; sortunl:=false; end;
  if code[8]='2' then begin tempdir:=dir_maphacks; sortunl:=false; end;
  if code[8]='3' then begin tempdir:=dir_gamehacks; sortunl:=false; end;
  if code[8]='1' then begin tempdir:=dir_hacked; sortunl:=false; end;
  if code[9]='1' then begin tempdir:=dir_bad; sortunl:=false; end;
  if code[3]>'0' then begin tempdir:=dir_europe; sortunl:=true; end;
  if code[1]>'0' then begin tempdir:=dir_japan; sortunl:=true; end;
  if code[2]>'0' then begin tempdir:=dir_northamerica; sortunl:=true; end;
  if code[4]>'0' then begin tempdir:=dir_asia; sortunl:=true; end;
  if code[5]='1' then begin tempdir:=dir_vs; sortunl:=false; end;
  if code[5]='2' then begin tempdir:=dir_pc10; sortunl:=false; end;
  if code[5]='3' then begin tempdir:=dir_pd; sortunl:=false; end;
  if code[6]='1' then begin tempdir:=dir_trans; sortunl:=false; end;
  if code='PIRATE' then begin tempdir:=dir_pirate; sortunl:=false; end;
  if code='MAPHACKS' then begin tempdir:=dir_maphacks; sortunl:=false; end;
  if code='GAMEHACKS' then begin tempdir:=dir_gamehacks; sortunl:=false; end;
  if code='HACKED' then begin tempdir:=dir_hacked; sortunl:=false; end;
  if code='BAD' then begin tempdir:=dir_bad; sortunl:=false; end;
  sortdir:=tempdir;
end;

procedure MoveROM(SourcePath,DestPath:string;var ErrCode:integer;crc:string='';ccode:string='');
var
  sf,df,f:file;
  SResult,DResult,fhandle:integer;
  buf:array[1..32768] of byte;
  sp,sn,dp,dn,sptemp,dptemp:string;
  existb,garbage:boolean;
  ctr,p:integer;
  newcrc,dnc,dummy,fext:string;

begin
  errcode:=0;
  ctr:=0;
  sn:=''; sp:=''; dn:=''; dp:='';
  SplitPath(SourcePath,sp,sn,GetCurrentDir+'\');
  SplitPath(DestPath,dp,dn,cpath);
  if dn='' then dn:=sn;
  if ForceDirectories(dp)=true then
    begin
      SourcePath:=ExtractShortPathname(sp)+sn;
      DestPath:=ExtractShortPathname(dp)+dn;
      dnc:=dn;
      if UpperCase(Sourcepath)<>UpperCase(DestPath) then
        begin
          if (crc<>'') and (FileExists(destpath)) then
            begin
              GetNesCrc(DestPath,newcrc,dummy,garbage,0,0);
              if newcrc=crc then
                begin
                  flagrom:=false;
                  dp:=dir_dupes;
                  DestPath:=dp+dn;
                  if ForceDirectories(dp)=false then errcode:=1 else errcode:=0;
                  if errcode=0 then DestPath:=extractshortpathname(dp)+dn;
                end else
                if ccode<>'' then
                  begin
                    p:=pos(ccode,UpperCase(dnc));
                    if p>0 then delete(dnc,p,length(ccode)) else
                      begin
                        fext:=ExtractFileExt(dnc);
                        dnc:=ChangeFileExt(dnc,'')+ccode+fext;
                      end;
                    DestPath:=ExtractShortPathname(dp)+dnc;
                    if UpperCase(SourcePath)<>UpperCase(DestPath) then
                      begin
                        if FileExists(Destpath) then
                          begin
                            GetNesCrc(DestPath,newcrc,dummy,garbage,0,0);
                            if newcrc=crc then
                              begin
                                flagrom:=false;
                                dp:=dir_dupes;
                                DestPath:=dp+dn;
                                if ForceDirectories(dp)=false then errcode:=1 else errcode:=0;
                             end else errcode:=1;
                          end;
                      end else errcode:=1;
                  end else errcode:=1;
            end;
          if errcode=0 then
            begin
              repeat
                ctr:=ctr+1;
                existb:=FileExists(destpath);
                if existb=true then
                  begin
                    if ctr<10 then delete(DestPath,length(DestPath),1);
                    if ctr>=10 then delete(DestPath,length(DestPath)-1,2);
                    DestPath:=DestPath+IntToStr(ctr);
                  end;
              until existb=false;
              if UpperCase(ExtractFileDrive(sp))=UpperCase(ExtractFileDrive(dp)) then
                begin
                  AssignFile(f,SourcePath);
                  {$I-} Rename(f,DestPath); {$I+}
                  errcode:=ioresult;
                end else
                begin
                  AssignFile(sf,SourcePath);
                  AssignFile(df,DestPath);
                  reset(sf,1);
                  {$I-} rewrite(df,1); {$I+}
                  errcode:=ioresult;
                  if errcode=0 then
                    begin
                      repeat
                        BlockRead(sf,buf,sizeof(buf),sresult);
                        BlockWrite(df,buf,sresult,dresult);
                      until (sresult=0) or (sresult<>dresult);
                      CloseFile(df);
                    end;
                  CloseFile(sf);
                  if errcode=0 then
                    begin
                      AssignFile(f,SourcePath);
                      {$I-} Erase(f); {$I+}
                      ioresult;
                    end;
                end;
            end;
        end else
        begin
          errcode:=-1;
          if sn<>dn then
            begin
              AssignFile(f,SourcePath);
              {$I-} Rename(f,DestPath); {$I+}
              errcode:=ioresult;
            end;
        end;
    end else errcode:=1;
  if (errcode>0) and (NesCL.logging=true) then
    begin
      sptemp:=UpperCase(sp);
      dptemp:=UpperCase(dp);
      if (sptemp=dptemp) and (sn<>dn) then
        logoutput(logfile,'Unable to rename '+sn+' to '+dn+' in '+sp+'.',wrotelog);
      if (sptemp<>dptemp) and (sn=dn) then
        logoutput(logfile,'Unable to move '+sn+' from '+sp+' to '+dp+'.',wrotelog);
      if (sptemp<>dptemp) and (sn<>dn) then
        logoutput(logfile,'Unable to move '+sp+sn+' to '+dp+dn+'.',wrotelog);
    end;
  if errcode=0 then
    begin
      fhandle:=FileOpen(destpath,fmOpenReadWrite);
      errcode:=FileSetDate(fhandle,DateTimeToFileDate(Now));
      FileClose(fhandle);
    end;
end;

procedure GetDBaseInfo(count:integer;var fname:string;var DbaseInfo:TNeshdr);
begin
  fname:=NesDBase[count].name;
  dbaseinfo.setheader(NesDBase[count].header+null8);
  dbaseinfo.SetCountry(NesDBase[count].country);
end;

procedure SearchDbase(cs:string;var fnd:integer);
var
  low,low2,high,mid:integer;
  found:boolean;
begin
  fnd:=0;
  low:=1;
  low2:=1;
  high:=dbasecount+1;
  mid:=high;
  found:=false;
  while (found<>true) and (low2<mid) do
    begin
      low2:=low;
      mid:=(high+low) div 2;
      if NesDBase[mid].csum=cs then found:=true
        else if NesDBase[mid].csum>cs then high:=mid
          else low:=mid;
    end;
  if found=true then fnd:=mid;
end;

procedure SearchPRGDbase(cs:string;var fnd:integer);
var
  low,low2,high,mid:integer;
  found:boolean;
  dbstr:string[13];
  dbpos:integer;
begin
  dbpos:=0;
  fnd:=0;
  low:=1;
  low2:=1;
  high:=dbasecount+1;
  mid:=high;
  found:=false;
  while (found<>true) and (low2<mid) do
    begin
      low2:=low;
      mid:=(high-low) div 2+low;
      dbstr:=PrgCSumArray[mid];
      dbpos:=StrToInt(copy(dbstr,9,length(dbstr)-8));
      dbstr:=copy(dbstr,1,8);
      if dbstr=cs then found:=true
        else if dbstr>cs then high:=mid
          else low:=mid;
    end;
  if found=true then fnd:=dbpos;
end;

procedure LoadNesDbase;
var
  DBArray:Array[1..8] of String;
  f:text;
  s:string;
  csprg:string[13];
  p,code:integer;
  byte7,byte8,prgbank,chrbank:byte;
begin
  dbasecount:=0;
  FCCount:=0;
  AssignFile(f,progpath+dbasefile);
  {$I-} reset(f); {I+}
  if ioresult>0 then
    begin
      rewrite(f);
      reset(f);
    end;
  while not eof(f) do
    begin
      dbasecount:=dbasecount+1;
      readln(f,s);
      DBLineParse(s,DBArray);
      NesDBase[dbasecount].csum:=DBArray[1];
      NesDBase[dbasecount].flag:=false;
      NesDBase[dbasecount].resize:=0;
      p:=pos('*',DBArray[2]);
      if p=0 then csprg:=DBArray[2]+IntToStr(dbasecount) else
        begin
          fccount:=fccount+1;
          NesDBase[dbasecount].resize:=fccount;
          csprg:=Copy(DBArray[2],1,p-1)+IntToStr(dbasecount);
          delete(DBArray[2],1,p);
          p:=pos(',',DBArray[2]);
          val(copy(DBArray[2],1,p-1),FCPrg[fccount],code);
          delete(DBArray[2],1,p);
          val(DBArray[2],FCChr[fccount],code);
        end;
      PrgCSumArray[dbasecount]:=csprg;
      NesDBase[dbasecount].name:=DBArray[3];
      val(DBArray[4],byte7,code);
      val(DBArray[5],byte8,code);
      val(DBArray[6],prgbank,code);
      val(DBArray[7],chrbank,code);
      NesDBase[dbasecount].header:=hdrstring+chr(prgbank)+chr(chrbank)+chr(byte7)+chr(byte8);
      NesDBase[dbasecount].country:=DBArray[8];
    end;
  CloseFile(f);
  if dbasecount>0 then quicksort(PrgCSumArray,1,dbasecount,False);
end;

function formatoutput(fname:string;var minfo:TNesHdr;docsum:boolean;csum:string;rflag:integer;l:integer;view_bl:boolean):string;
var
  outp:string;
  ns:string;
  split:boolean;
  fname2:string;
  c:char;
  count:integer;
  otemp:string[5];
begin
  outp:='';
  split:=false;
  if length(fname)>l then
    begin
      count:=l;
      split:=true;
      repeat
        c:=fname[count];
        count:=count-1;
      until (c=' ') or (c='_') or (count=0);
      if count=0 then split:=false;
      if split=true then
        begin
          fname2:=copy(fname,count+2,length(fname)-count-1);
          delete(fname,count+1,length(fname)-count);
        end;
    end;
  str(minfo.mapper,ns);
  if rflag=0 then outp:=outp+'  ';
  if rflag=1 then outp:=outp+'? ';
  if rflag=2 then outp:=outp+'* ';
  if rflag=3 then outp:=outp+'x ';
  if rflag=4 then outp:=outp+'n ';
  if rflag=5 then outp:=outp+'d ';
  if rflag=6 then outp:=outp+'b ';
  outp:=outp+justify(fname,l,'L',true);
  outp:=outp+' '+justify(ns,3,'R',False)+' ';
  if minfo.mirror=0 then outp:=outp+'H' else outp:=outp+'V';
  if minfo.sram=0 then outp:=outp+'.' else outp:=outp+'B';
  if minfo.trainer=0 then outp:=outp+'.' else outp:=outp+'T';
  if minfo.fourscr=0 then outp:=outp+'.' else outp:=outp+'4';
  if view_bl=false then
    begin
      str(minfo.prgbank*16,ns);
      outp:=outp+' '+justify(ns,4,'R',False)+'kB';
      if minfo.chrbank>0 then
        begin
          str(minfo.chrbank*8,ns);
          outp:=outp+' '+justify(ns,4,'R',False)+'kB';
        end else outp:=outp+'  -----';
    end else
    begin
      str(minfo.prgbank,ns);
      outp:=outp+' '+justify(ns,2,'R',False)+'x16kB';
      if minfo.chrbank>0 then
        begin
          str(minfo.chrbank,ns);
          outp:=outp+' '+justify(ns,2,'R',False)+'x8kB';
        end else outp:=outp+'  -----';
    end;
  if docsum=true then
    begin
      otemp:='     ';
      if copy(minfo.country,1,5)='00000' then otemp:=' ??? ';
      if minfo.country[1]='1' then otemp[2]:='J';
      if minfo.country[2]='1' then otemp[3]:='U';
      if minfo.country[3]='1' then otemp[4]:='E';
      if minfo.country[10]='1' then otemp[5]:='@';
      if minfo.country[2]='2' then otemp:=' Can ';
      if minfo.country[3]='2' then otemp:=' Fra ';
      if minfo.country[3]='3' then otemp:=' Ger ';
      if minfo.country[3]='4' then otemp:=' Spa ';
      if minfo.country[3]='5' then otemp:=' Swe ';
      if minfo.country[3]='6' then otemp:=' Ita ';
      if minfo.country[3]='7' then otemp:=' Aus ';
      if minfo.country[4]='1' then otemp:=' Asi ';
      if minfo.country[5]='1' then otemp:=' VS  ';
      if minfo.country[5]='2' then otemp:=' P10 ';
      if minfo.country[5]='3' then otemp:=' PD  ';
      if minfo.country[6]='1' then otemp:=' TR  ';
      if minfo.country[8]='3' then otemp:=' GH  ';
      outp:=outp+otemp;
    end;
  if docsum=true then outp:=outp+csum;
  if split=true then outp:=outp+#27+'     '+fname2;
  formatoutput:=outp;
end;

procedure checksplit(var s1:string;var s2:string);
var
  p:integer;
begin
  s2:='';
  p:=pos(#27,s1);
  if p>0 then
    begin
      s2:=copy(s1,p+1,length(s1)-p);
      delete(s1,p,length(s1)-p+1);
    end;
end;

procedure parsemissing(missingpath:string);
var
  f2:text;
  flags:array[1..maxdbasesize] of boolean;
  ctr,result:integer;
  s:string;
begin
  for ctr:=1 to dbasecount do
    flags[ctr]:=false;
  assign(f2,missingpath);
  reset(f2);
  while not eof(f2) do
    begin
      readln(f2,s);
      if s<>'' then
        while s[length(s)]=' ' do delete(s,length(s),1);
      s:=copy(s,length(s)-7,8);
      SearchDbase(s,result);
      if result>0 then flags[result]:=true;
    end;
  close(f2);
  for ctr:=1 to dbasecount do
    if flags[ctr]=false then NesDBase[ctr].flag:=true;
end;

function shortparse(name:string;shorten:boolean):string;
var
  p,p2:integer;
begin
  p:=pos('<',name);
  p2:=pos('>',name);
  while (p>0) and (p2>p) do
    begin
      delete(name,p2,1);
      delete(name,p,1);
      if shorten=true then
        delete(name,p,p2-p-1);
      p:=pos('<',name);
      p2:=pos('>',name);
    end;
  shortparse:=name;
end;

procedure listmissing(showall,csort:boolean);
var
  f:text;
  io2,c,acount:integer;
  badcount:integer;
  fn,outp,out2:string;
  dbaseinfo:TNeshdr;
  csum:string[8];
  dbasearray:array[1..maxdbasesize] of string;
  missingpath:string;
  country:string[3];
  skipflag:boolean;

begin
  dbaseinfo:=TNesHdr.Create;
  acount:=0;
  badcount:=0;
  missingpath:=cpath+missingfile;
  AssignFile(f,missingpath);
  if (fileexists(missingpath)) and (NesCL.overwritemissing=false) then parsemissing(missingpath);
  {$I-} rewrite(f); {$I+}
  io2:=ioresult;
  if io2=0 then
    begin
      for c:=1 to dbasecount do
        begin
          csum:=NesDBase[c].csum;
          fn:=shortparse(NesDBase[c].name,false);
          dbaseinfo.SetHeader(NesDBase[c].header+null8);
          dbaseinfo.SetCountry(NesDBase[c].country);
          skipflag:=false;
          if (dbaseinfo.country[6]='1') and (missing_trans=false) then skipflag:=true;
          if (dbaseinfo.country[7]='1') and (missing_pirate=false) then skipflag:=true;
          if (dbaseinfo.country[8]='1') and (missing_hacked=false) then skipflag:=true;
          if (dbaseinfo.country[8]='2') and (missing_hacked=false) then skipflag:=true;
          if (dbaseinfo.country[8]='3') and (missing_gamehacks=false) then skipflag:=true;
          if (dbaseinfo.country[9]='1') and (missing_bad=false) then skipflag:=true;
          if NesDBase[c].resize>0 then skipflag:=true;
          if skipflag=true then badcount:=badcount+1;
          if (NesDBase[c].flag=false) and (skipflag=false) then
            begin
              acount:=acount+1;
              outp:=formatoutput(fn,dbaseinfo,true,csum,0,41,false);
              delete(outp,1,2);
              country:=copy(outp,66,3);
              if (csort=true) and (showall=true) then
                begin
                  delete(outp,66,3);
                  outp:=country+outp;
                end;
              if showall=false then
                begin
                  if country='J E' then country:='JE ';
                  outp:=fn+' ('+removespaces(country,true)+') - '+csum;
                end;
              if (csort=true) and (showall=false) then outp:=country+outp;
              dbasearray[acount]:=outp;
            end;
        end;
      if acount>0 then quicksort(dbasearray,1,acount,False);
      if acount>0 then
        for c:=1 to acount do
          begin
            out2:='';
            outp:=dbasearray[c];
            if csort=true then
              begin
                country:=copy(outp,1,3);
                delete(outp,1,3);
                if showall=true then insert(country,outp,66);
              end;
            if showall=true then checksplit(outp,out2);
            writeln(f,outp);
            if out2<>'' then writeln(f,out2);
          end;
      writeln(f);
      writeln(f,acount,' missing',AddS(' ROM',acount),' out of ',dbasecount-badcount);
      CloseFile(f);
      dbaseinfo.free;
    end;
  if io2>0 then
    begin
      writeln;
      write('Error: Cannot create ',missingpath);
    end;
end;

procedure usage(t:byte);
begin
write('NesToy32 ',version,' - (c)2000, D-Tox Software  ');
if private_build=false then writeln('(',webpage,')') else
  writeln('(Private Build - DO NOT DISTRIBUTE!!)');
writeln;
if (t=0) or (t=1) then
  begin
    writeln('usage: NesToy [parameters] pathname1 [pathname2] [pathname3] ...');
    if t=0 then writeln;
    if t=0 then writeln('Type NesToy -help for command line parameters');
    if t=0 then writeln;
  end;
if t=1 then
  begin
    writeln('Parameters:');
    writeln('-b             Display PRG and CHR banks by # of blocks instead of kB');
    writeln('-c             Calculate Checksums (CRC 32)');
    writeln('-i             Outputs extended info if header or name are not correct');
    writeln('-o[file]       Sends output to file (DOS 8.3 filenames for now)');
    writeln('-ren[uscltp]   Renames ROMs to names stored in database (enables -c)');
    writeln('                  u- Replace spaces with underscores');
    writeln('                  s- Remove spaces completely from filename');
    writeln('                  c- Attach country codes to end of filenames');
    writeln('                  l- Convert ROMs to all lowercase names');
    writeln('                  t- Places the word "The" at the beginning of ROM names');
    writeln('                     instead of at the end.');
    writeln('                  a- Places the words "A", "An", etc. at the beginning of');
    writeln('                     ROM names instead of at the end.');
    writeln('                  p- Use periods in appropriate ROM names (Warning: Nesticle');
    writeln('                     will not load ROMs with extra periods in them.');
    writeln('-rep,-repair   Repairs ROM headers with those found in database (enables -c)');
    writeln('-res,-resize   Automatically resizes ROMs if they contain duplicate or');
    writeln('               unused banks of data.');
    writeln('-ips           Patches a ROM if an appropriate IPS patch is found in the');
    writeln('               fixfiles directory.  IPS patches are named by the checksum of');
    pause;
    writeln('               the ROM they are meant to patch.');
    writeln('-sort[mb]      Sorts ROMs into directories by region or type');
    writeln('                  m- Sorts ROMs by mapper # as well');
    writeln('                  b- Sorts "Bad CHR" dumps into a CHR directory in the');
    writeln('                     Bad Dump directory.');
    writeln('-m#            Filter listing by mapper #');
    writeln('-f[hvbt4]      Filter listing by mapper data');
    writeln('                  h- Horizontal Mirroring     t- Trainer Present');
    writeln('                  v- Vertical Mirroring       4- 4 Screen Buffer');
    writeln('                  b- Contains SRAM (Battery backup)');
    writeln('-u             Only display unknown ROMs (enables -c)');
    writeln('-sub           Process all subdirecories under directories specified on path');
    writeln('-missing[cbn]  Create a listing of missing ROMs.  If listing exists, it will be');
    writeln('               updated.  Filename is defined in ',cfgfile,'.');
    writeln('                  c- Sort missing list by country');
    writeln('                  b- Bare listing (Name, country codes, and checksum only)');
    writeln('                  n- Force NesToy to create a new missing list, even if one');
    writeln('                     already exists (It will be overwritten.)');
    writeln('-nobackup      Don''t make backups before repairing or resizing ROMs');
    writeln('-log           Log to ',logfile,' any problems NesToy encounters while sorting,');
    writeln('               renaming, or repairing ROMs.');
    writeln('-q[o]          Suppresses output to the screen (for those of you who would');
    writeln('               prefer not to see what NesToy is up to.)');
    writeln('                  o- Suppresses output to the output file as well.');
    pause;
    writeln('-doall         Enables -c,-i,-ren,-repair,-resize,-sort, and -missing');
    writeln('-h,-?,-help    Displays this screen');
    writeln;
    writeln('Filename can include wildcards (*,?) anywhere inside the filename.  Long');
    writeln('file names are allowed.  If no filename is given, (*.nes) is assumed.');
  end;
if t=2 then
  begin
    writeln('NesToy is unable to locate any .ips files in');
    writeln(dir_fixfiles,'.');
    writeln;
    writeln('To use the -ips command line option, you must unzip the FixFiles archive');
    writeln('into the above directory.  If you do not have the FixFiles archive, you can');
    writeln('always download the latest release from ',webpage,'.');
  end;
  halt;
end;

var
  f:word;
  csum,prgcsum:string;
  clfname,pathname,sortdir:string;
  l,lr:integer;
  rflag,counter:integer;
  matchcount,nomove,prgcount,rncount,romcount,rpcount,rscount,fixcount:integer; {ROM Counters}
  dirromcount:integer;
  dbpos,io,pc,wy:integer;
  fcpos:integer;
  namematch,cmp,abort:boolean;
  booltemp,shorten:boolean;
  repairdiradded:boolean;
  result,rtmp,rtmp2,ralt:string;
  key:char;
  outm:string[13];
  ofile:text;
  errcode:integer;
  name:string;
  newprg,newchr:byte;
  sortcode:string[10];
  startdt,enddt,filedt,diffdt:tdatetime;
  hour,min,sec,sec100:word;
  fs:integer;

procedure initialize;
var
  pc:integer;
begin
  progpath:=ExtractFilePath(paramstr(0));
  cpath:=getcurrentdir;
  if cpath[length(cpath)]<>'\' then cpath:=cpath+'\';
  LoadNesDbase;
  LoadNesCfgFile(progpath);
  pathname:='';
  matchcount:=0; nomove:=0; prgcount:=0; rncount:=0; romcount:=0; rpcount:=0; rscount:=0;
  fixcount:=0;
  abort:=false;
  repairdiradded:=false;
  wrotelog:=false;
  NesCL:=TNesCmdLine.Create(Param_Ren,Param_Missing);
  if paramcount=0 then usage(0);
  if NesCL.help=true then usage(1);
  if (NESCL.fix=true) and (CountDir(dir_fixfiles+'*.ips')=0) then usage(2);
  if NesCL.no_backup=true then no_backup:=true;
  logfile:=cpath+logfile;
  for pc:=1 to paramcount+1 do
    begin
      if pc>paramcount then
        begin
          if dirpaths.count=0 then clfname:='*.nes' else clfname:='-';
        end else clfname:=paramstr(pc);
      if (clfname[1]<>'-') and (dirpaths.count<maxpathnames) then
        begin
          splitpath(clfname,pathname,clfname,cpath);
          if clfname='' then clfname:='*.nes';
          DirPaths.AddPath(pathname,clfname,NesCL.subdir,dirlimit);
        end;
    end;
  if NesCL.outfile=true then
    begin
      if NesCL.Outputfile='' then NesCL.Outputfile:=Outputfile;
      result:=cpath+NesCL.Outputfile;
      assign(ofile,result);
      {$I-} reset(ofile); {$I+}
      io:=ioresult;
      if io>0 then rewrite(ofile) else append(ofile);
      if ioresult>0 then
        begin
          write('Error: Cannot create ',result);
          halt;
        end;
      if io=0 then begin
                     writeln(ofile);
                     writeln(ofile,'------------------------------------------------------------------------------');
                   end;
    end;
end;

procedure main;
var
  badrom,dupe,ghackedrom,hackedrom,mhackedrom,piraterom:boolean;
  cropped,fixed,notrenamed,notrepaired,sorted:boolean;
  garbage,prgfound,show,unlflag,sortunl:boolean;
  outp,out2:string;
  nes,oldnes,resulthdr:TNESHdr;
  byte7,byte8:byte;
  attrib:word;
  ferase:file;
begin
  outp:=''; out2:='';
  flagrom:=true;
  show:=true;
  garbage:=false;
  notrenamed:=false; notrepaired:=false;
  cropped:=false; fixed:=false; sorted:=false;
  badrom:=false; dupe:=false; ghackedrom:=false;
  hackedrom:=false; mhackedrom:=false; piraterom:=false;
  prgfound:=false; unlflag:=false;
  nes:=TNesHdr.Create;
  oldnes:=TNESHdr.Create;
  resulthdr:=TNESHdr.Create;
  fcpos:=0;
  attrib:=FileGetAttr(Name);
  if (attrib and faReadOnly)=1 then
      FileSetAttr(Name,attrib xor FaReadOnly);
  nes.ReadFromFile(Name);
  if nes.hdr<>hdrstring then show:=false;
  if NesCL.msearch>-1 then if nes.mapper<>NesCL.msearch then show:=false;
  if (NesCL.show_h=true) and (nes.mirror=1) then show:=false;
  if (NesCL.show_v=true) and (nes.mirror=0) then show:=false;
  if (NesCL.show_b=true) and (nes.sram=0) then show:=false;
  if (NesCL.show_t=true) and (nes.trainer=0) then show:=false;
  if (NesCL.show_4=true) and (nes.fourscr=0) then show:=false;
  if (NesCL.docsum=true) and (show=true) then
    begin
      GetNesCrc(Name,csum,prgcsum,garbage,nes.prgbank,nes.trainer);
      SearchDBase(csum,dbpos);
      if NesCL.resize=true then
        begin
          if (dbpos>0) and (NesDBase[dbpos].resize>0) then
            begin
              fcpos:=NesDBase[dbpos].resize;
              dbpos:=0;
            end;
          if dbpos=0 then
            begin
              fs:=GetFileSize(name) div 8192;
              if FCPos=0 then CheckNesBanks(Name,nes.prgbank,nes.chrbank,newprg,newchr);
              if FCPos>0 then begin newprg:=fcprg[fcpos]; newchr:=fcchr[fcpos]; end;
              if (nes.prgbank<>newprg) or (nes.chrbank<>newchr) or (fs>nes.prgbank*2+nes.chrbank) then
                begin
                  oldnes.SetHeader(Nes.GetHeader);
                  CropNesRom(Name,nes,newprg,newchr,errcode);
                  if (errcode>0) and (NesCL.logging=true) then
                    logoutput(logfile,'Unable to resize '+getcurrentdir+'\'+name+'.',wrotelog);
                  if errcode=0 then
                    begin
                      rtmp:=changefileext(name,'');
                      if no_backup=true then
                        begin
                          assign(ferase,rtmp+'.bak');
                          {$I-} erase(ferase); {$I+}
                          ioresult;
                        end else
                      MoveROM(rtmp+'.bak',dir_backup,errcode);
                      rscount:=rscount+1;
                      cropped:=true;
                      GetNesCrc(Name,csum,prgcsum,garbage,nes.prgbank,nes.trainer);
                      SearchDBase(csum,dbpos);
                    end else notrepaired:=true;
                end;
            end;
        end;
      if NesCL.fix=true then
        if FileExists(dir_fixfiles+csum+'.ips') then
          begin
            ROMPatch(name,dir_fixfiles+csum+'.ips',errcode,no_backup);
            if errcode=0 then
              begin
                rtmp:=changefileext(name,'');
                if no_backup=false then
                  MoveROM(rtmp+'.bak',dir_backup,errcode);
                fixcount:=fixcount+1;
                fixed:=true;
                GetNesCrc(Name,csum,prgcsum,garbage,nes.prgbank,nes.trainer);
                SearchDBase(csum,dbpos);
              end else notrepaired:=true;
          end;
      if dbpos=0 then
        begin
          if (nes.prgbank<>0) and (nes.prgbank<>1) and (nes.prgbank<>2) and (nes.prgbank<>4) and
             (nes.prgbank<>8) and (nes.prgbank<>16) and (nes.prgbank<>32) and (nes.prgbank<>40) and
             (nes.prgbank<>64) and (nes.prgbank<>96) and (nes.prgbank<>128) then badrom:=true;
          if (nes.chrbank<>0) and (nes.chrbank<>1) and (nes.chrbank<>2) and (nes.chrbank<>4) and
             (nes.chrbank<>8) and (nes.chrbank<>16) and (nes.chrbank<>32) and (nes.chrbank<>64) and
             (nes.chrbank<>128) then badrom:=true;
          fs:=GetFileSize(name) div 8192;
          if fs<nes.prgbank*2+nes.chrbank then badrom:=true;
        end;
      if dbpos=0 then
        begin
          SearchPRGDBase(prgcsum,dbpos);
          if dbpos>0 then begin prgfound:=true; badrom:=true; prgcount:=prgcount+1; end;
        end;
      if (dbpos>0) and (prgfound=false) then
        begin
          if NesDBase[dbpos].flag=true then
            begin
              if NesCL.sort=true then
                begin
                  filedt:=filedatetodatetime(fileage(name));
                  if filedt<startdt-(3/86400) then dupe:=true;
                end else dupe:=true;
            end;
        end;
      if NesCL.unknown=true then show:=false;
      if (NesCL.unknown=true) and (dbpos=0) then show:=true;
    end;
  if show=true then
    begin
      if dbpos=0 then result:=changefileext(name,'');
      settitle(title+' - '+result);
      if NesCL.docsum=true then rflag:=1 else rflag:=-1;
      romcount:=romcount+1;
      dirromcount:=dirromcount+1;
      if (dbpos=0) and (badrom=true) then rflag:=6;
      if (dbpos>0) and (NesCL.dbase=false) then
        begin
          rflag:=2;
          if prgfound=false then matchcount:=matchcount+1;
          getdbaseinfo(dbpos,result,resulthdr);
          shorten:=shortname;
          lr:=length(result);
          if pos('<',result)>0 then lr:=lr-2;
          if (joliet=true) and (lr>60) then shorten:=true;
          result:=shortparse(result,shorten);
          if pos('(UNL',UpperCase(result))=0 then unlflag:=true;
          if (unlflag=true) and (tagunl=true) and (resulthdr.country[10]='1') then
            result:=result+' (Unl)';
          if prgfound=true then
            begin
              result:=result+badchr+' '+csum+')';
              resulthdr.chrbank:=nes.chrbank;
            end;
          nes.country:=resulthdr.country;
          if nes.country[7]='1' then piraterom:=true;
          if nes.country[8]='2' then mhackedrom:=true;
          if nes.country[8]='3' then ghackedrom:=true;
          if nes.country[8]='1' then hackedrom:=true;
          if nes.country[9]='1' then badrom:=true;
          ralt:=result;
          if (NesCL.ccode=true) or (nes.country[2]>'1') or (nes.country[3]>'1') then
            result:=result+nes.getcountry;
          if (NesCL.mthe=true) or (NesCL.ma=true) then
            result:=moveword(result,NesCL.mthe,NesCL.ma);
          if NesCL.lowcasename=true then result:=LowerCase(result);
          if NesCL.remspace=true then result:=SpaceCvt(result,false);
          if NesCL.uscore=true then result:=SpaceCvt(result,true);
          if NesCL.remperiod=true then result:=PeriodCvt(result);
          cmp:=nes.compare(resulthdr.getheader);
          if result+'.nes'<>name then namematch:=false else namematch:=true;
          if (namematch=false) and (NesCL.rname=false) then
            namematch:=checkname(name,ralt,nes.getcountry);
          if result[length(result)]='.' then delete(result,length(result),1);
          if badrom=true then rflag:=6;
          if namematch=false then rflag:=4;
          if (cmp=false) or (garbage=true) then rflag:=3;
          if dupe=true then rflag:=5;
        end;
      if NesCL.dbase=false then
        begin
          if cropped=true then
            begin
              if (NesCL.quiet=false) or (NesCL.extout=true) then
                begin
                  outp:=formatoutput(name,oldnes,NesCL.docsum,' Resized',1,l,NesCL.view_bl);
                  checksplit(outp,out2);
                  if NesCL.quiet=true then gotoxy(1,wy);
                  writeln(outp);
                  if out2<>'' then writeln(out2);
                  if NesCL.quiet=true then
                    begin
                      if wy=24 then writeln;
                      if wy<24 then wy:=wherey;
                    end;
                end;
              if (NesCL.outfile=true) and ((NesCL.extout=true) or (NesCL.outquiet=false)) then
                begin
                  writeln(ofile,outp);
                  if out2<>'' then writeln(ofile,out2);
                end;
            end;
          outp:=formatoutput(name,nes,NesCL.docsum,csum,rflag,l,NesCL.view_bl);
          checksplit(outp,out2);
        end else
        begin
          if NesCL.extdbase=false then
            begin
              outp:=outp+csum+';'+prgcsum+';'+changefileext(name,'');
              byte7:=nes.mirror+nes.sram*2+nes.trainer*4+nes.fourscr*8+nes.basemapper mod 16*16;
              byte8:=nes.extmapper+nes.basemapper div 16*16;
              outp:=outp+';'+Int2Str(byte7,0);
              outp:=outp+';'+Int2Str(byte8,0);
              outp:=outp+';'+Int2Str(nes.prgbank,0);
              outp:=outp+';'+Int2Str(nes.chrbank,0);
            end else
            begin
              outp:=outp+'"'+csum+'","'+changefileext(name,'');
              outp:=outp+'"';
              outp:=outp+','+Int2Str(nes.mapper,0)+',';
              outp:=outp+Int2Str(nes.mirror,0)+','+Int2Str(nes.sram,0)+',';
              outp:=outp+Int2Str(nes.trainer,0)+','+Int2Str(nes.fourscr,0)+',"';
              if nes.mirror=1 then outp:=outp+'V' else outp:=outp+'H';
              if nes.sram=1 then outp:=outp+'B' else outp:=outp+'.';
              if nes.trainer=1 then outp:=outp+'T' else outp:=outp+'.';
              if nes.fourscr=1 then outp:=outp+'4' else outp:=outp+'.';
              outp:=outp+'",'+Int2Str(nes.prgbank,0)+','+Int2Str(nes.chrbank,0);
            end;
        end;
      sortcode:=nes.country;
      if (piraterom=true) and (move_pirate=true) then sortcode:='PIRATE';
      if (mhackedrom=true) and (move_hacked=true) then sortcode:='MAPHACKS';
      if ghackedrom=true then sortcode:='GAMEHACKS';
      if (hackedrom=true) and (move_hacked=true) then sortcode:='HACKED';
      if (badrom=true) and (move_bad=true) then sortcode:='BAD';
      if (NesCL.quiet=true) and (NesCL.dbase=false) then
        begin
          gotoxy(1,wy);
          writeln(dirromcount,' ROMs scanned.');
        end else
        begin
          writeln(outp);
          if out2<>'' then writeln(out2);
        end;
      if (NesCL.outfile=true) and (NesCL.outquiet=false) then
        begin
          writeln(ofile,outp);
          if out2<>'' then writeln(ofile,out2);
        end;
      if (dbpos>0) and (NesCL.dbase=false) then
        begin
          if (NesCL.repair=true) and ((cmp=false) or (garbage=true)) then
            begin
              WriteNesHdr(name,resulthdr,errcode,no_backup);
              if (errcode>0) and (NesCL.logging=true) then
                logoutput(logfile,'Unable to repair '+getcurrentdir+'\'+name+'.',wrotelog);
              if errcode=0 then
                begin
                  rpcount:=rpcount+1;
                  rtmp:=changefileext(name,'');
                  if no_backup=false then
                    MoveROM(rtmp+'.bak',dir_backup,errcode);
                end;
              if errcode>0 then notrepaired:=true;
            end;
          if (NesCL.rname=true) and (dupe=false) then
          if result+'.nes'<>name then
            begin
              if NesCL.sort=true then
                begin
                  sorted:=true;
                  getsortdir(sortcode,sortdir,sortunl);
                  if (move_bad=true) and (badrom=true) and (prgfound=true) and (NesCL.sortbadchr=true)
                    then sortdir:=sortdir+'CHR\';
                  if (sort_trans=true) and (nes.country[6]='1') then sortdir:=sortdir+transdir(result)+'\';
                  if (sort_unlicensed=true) and (sortunl=true) and (nes.country[10]='1') then
                    sortdir:=sortdir+'Unlicensed\';
                  if NesCL.sortmapper=true then sortdir:=sortdir+Int2Str(resulthdr.mapper,3)+'\';
                  if notrepaired=true then
                    begin
                      sortdir:=dir_repair;
                      if repairdiradded=false then
                        begin
                          repairdiradded:=true;
                          dirpaths.AddPath(dir_repair,'*.*');
                        end;
                    end;
                end else sortdir:=getcurrentdir+'\';
              MoveROM(name,sortdir+result+'.nes',errcode,csum,nes.getcountry);
              if errcode=0 then rncount:=rncount+1 else
                begin
                  notrenamed:=true;
                  if errcode<>100 then nomove:=nomove+1;
                end;
            end;
          if (NesCL.extout=true) and ((cmp=false) or (namematch=false) or (garbage=true)) then
            begin
              if NesCL.quiet=true then
                begin
                  gotoxy(1,wy);
                  writeln(outp);
                  if out2<>'' then writeln(out2);
                end;
              if (NesCL.outfile=true) and (NesCL.outquiet=true) then
                begin
                  writeln(ofile,outp);
                  if out2<>'' then writeln(ofile,out2);
                end;
              outp:=formatoutput(result,resulthdr,false,'',0,l,NesCL.view_bl);
              checksplit(outp,out2);
              outm:='   Bad [----]';
              if (NesCL.rname=true) and (namematch=false) then outm:='   Ren [----]';
              if (NesCL.repair=true) and (cmp=false) then outm:='   Rep [----]';
              if namematch=false then outm[9]:='N';
              if cmp=false then outm[10]:='H';
              if nes.other<>null8 then outm[11]:='G';
              if garbage=true then outm[12]:='T';
              if notrenamed=true then outm:=' Can''t Rename';
              if notrepaired=true then outm:=' Can''t Repair';
              outp:=outp+outm;
              writeln(outp);
              if out2<>'' then writeln(out2);
              writeln;
              if (NesCL.quiet=true) and (wy<24) then wy:=wherey-1;
              if NesCL.outfile=true then
                begin
                  writeln(ofile,outp);
                  if out2<>'' then writeln(ofile,out2);
                  if NesCL.quiet=false then writeln(ofile);
                end;
            end;
        end;
      if (NesCL.sort=true) and (dupe=false) and (sorted=false) then
        begin
          if (dbpos=0) and (sortcode<>'BAD') then sortdir:=dir_unknown else
            getsortdir(sortcode,sortdir,sortunl);
          if (move_bad=true) and (badrom=true) and (prgfound=true) and (NesCL.sortbadchr=true)
            then sortdir:=sortdir+'CHR\';
          if (sort_trans=true) and (dbpos>0) and (nes.country[6]='1') then
            sortdir:=sortdir+transdir(result)+'\';
          if (sort_unlicensed=true) and (sortunl=true) and (nes.country[10]='1') then
            sortdir:=sortdir+'Unlicensed\';
          if NesCL.sortmapper=true then
            begin
              if dbpos>0 then sortdir:=sortdir+Int2Str(resulthdr.mapper,3)+'\'
                         else sortdir:=sortdir+Int2Str(nes.mapper,3)+'\';
            end;
          if notrepaired=true then
            begin
              sortdir:=dir_repair;
              if repairdiradded=false then
                begin
                  repairdiradded:=true;
                  dirpaths.AddPath(dir_repair,'*.*');
                end;
            end;
          MoveROM(name,sortdir,errcode,csum,nes.getcountry);
          if (errcode>0) and (errcode<>100) then nomove:=nomove+1;
        end;
      if dupe=true then
      if (NesCL.rname=true) and (result+'.nes'<>name) then
        begin
          MoveROM(name,dir_dupes+result+'.nes',errcode);
          if errcode=0 then rncount:=rncount+1;
        end else MoveROM(name,dir_dupes,errcode);
      if (dbpos>0) and (flagrom=true) and (prgfound=false) then
        NesDBase[dbpos].flag:=true;
      if (NesCL.rname=true) and (notrenamed=false) and (dbpos>0) then
        begin
          if dir_savestates<>'' then if result+'.nes'<>name then renamemask(name,result,dir_savestates);
          if dir_patches<>''then if result+'.nes'<>name then renamemask(name,result,dir_patches);
        end;
    end;
  nes.free;
  oldnes.free;
  resulthdr.free;
end;

begin
  settitle(title);
  setbreakhandler(true);
  setcheckctrlc(false);
  DirPaths:=PathArray.Create(maxdirsize);
  initialize;
  if NesCL.docsum=false then l:=55 else l:=40;
  StartDt:=now;
  pc:=0;
  while (pc<dirpaths.Count) and (abort=false) do
    begin
      pc:=pc+1;
      dirromcount:=0;
      splitpath(dirpaths.GetPath(pc),pathname,clfname);
      if (UpperCase(pathname)<>UpperCase(dir_dupes)) and
         (UpperCase(pathname)<>Uppercase(dir_backup)) or (NesCL.subdir=false) then
        begin
          writeln;
          if NesCL.outfile=true then writeln(ofile);
          write(pathname,clfname);
          if NesCL.outfile=true then write(ofile,pathname,clfname);
          {$I-} ChDir(pathname); {$I+}
          if ioresult>0 then
            begin
              writeln(' [Path Not Found]');
              if NesCL.outfile=true then writeln(ofile,' [Path Not Found]');
            end else
            begin
              writeln;
              if NesCL.outfile=true then writeln(ofile);
              if NesCL.quiet=true then begin writeln; wy:=wherey-1; end;
              f:=ReadDir(clfname,DirArray);
              if f>0 then quicksort(dirarray,1,f,True);
              for counter:=1 to f do
                if abort=false then
                  begin
                    name:=dirarray[counter];
                    if keypressed=true then
                      begin
                        key:=readkey;
                        if key=#27 then abort:=true;
                      end;
                    main;
                  end;
              ChDir(cpath);
            end;
        end;
    end;
  DirPaths.Free;
  enddt:=now;
  diffdt:=enddt-startdt;
  decodetime(diffdt,hour,min,sec,sec100);
  if romcount=0 then writeln('No ROMs found') else begin writeln; writeln(romcount,AddS(' ROM',romcount),' found'); end;
  if matchcount>0 then writeln(matchcount,AddS(' ROM',matchcount),' found in database');
  if prgcount>0 then writeln(prgcount,AddS(' ROM',prgcount),' found with bad CHR banks');
  if rpcount>0 then writeln(rpcount,AddS(' ROM',rpcount),' repaired');
  if rncount>0 then writeln(rncount,AddS(' ROM',rncount),' renamed');
  if rscount>0 then writeln(rscount,AddS(' ROM',rscount),' resized');
  if fixcount>0 then writeln(fixcount,AddS(' Bad Dump',fixcount),' fixed');  
  if nomove>0 then writeln('Unable to sort ',nomove,AddS(' ROM',nomove));
  writeln;
  write('Finished in ');
  if hour>0 then write(hour,AddS(' hour',hour),', ');
  if min>0 then write(min,AddS(' minute',min),' and ');
  writeln(sec,AddS(' second',sec),'.');
  if (NesCL.outfile=true) and (NesCL.dbase=false) then
    begin
      if romcount=0 then writeln(ofile,'No ROMs found')
      else begin writeln(ofile); writeln(ofile,romcount,AddS(' ROM',romcount),' found'); end;
      if matchcount>0 then writeln(ofile,matchcount,AddS(' ROM',matchcount),' found in database');
      if prgcount>0 then writeln(ofile,prgcount,AddS(' ROM',prgcount),' found with bad CHR banks');
      if rpcount>0 then writeln(ofile,rpcount,AddS(' ROM',rpcount),' repaired');
      if rncount>0 then writeln(ofile,rncount,AddS(' ROM',rncount),' renamed');
      if rscount>0 then writeln(ofile,rscount,AddS(' ROM',rscount),' resized');
      if fixcount>0 then writeln(ofile,fixcount,AddS(' Bad Dump',fixcount),' fixed');
      if nomove>0 then writeln(ofile,'Unable to sort ',nomove,AddS(' ROM',nomove));
      writeln(ofile);
      write(ofile,'Finished in ');
      if hour>0 then write(ofile,hour,AddS(' hour',hour),', ');
      if min>0 then write(ofile,min,AddS(' minute',min),' and ');
      writeln(ofile,sec,AddS(' second',sec),'.');
    end;
  if NesCL.outfile=true then close(ofile);
  if directoryexists(dir_repair) then
    begin
      {$I-} rmdir(dir_repair); {$I+}
      ioresult;
    end;
  if NesCL.dbasemissing=true then listmissing(NesCL.allmissing,NesCL.missingsort);
  NesCL.free;
end.
