------------------------------------------------------------------------------
--                              Ada Web Server                              --
--                                                                          --
--                     Copyright (C) 2003-2012, AdaCore                     --
--                                                                          --
--  This is free software;  you can redistribute it  and/or modify it       --
--  under terms of the  GNU General Public License as published  by the     --
--  Free Software  Foundation;  either version 3,  or (at your option) any  --
--  later version.  This software is distributed in the hope  that it will  --
--  be useful, but WITHOUT ANY WARRANTY;  without even the implied warranty --
--  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU     --
--  General Public License for  more details.                               --
--                                                                          --
--  You should have  received  a copy of the GNU General  Public  License   --
--  distributed  with  this  software;   see  file COPYING3.  If not, go    --
--  to http://www.gnu.org/licenses for a complete copy of the license.      --
------------------------------------------------------------------------------

with Ada.Strings.Fixed;
with Ada.Text_IO;

with AWS.Services.Directory;
with AWS.Status.Set;

procedure Dirop is

   use Ada;
   use AWS;

   Stat : Status.Data;

begin
   Status.Set.Request (Stat, "GET", "/", "HTTP/1.1");

   declare
      Result : constant String
        := Services.Directory.Browse
             (Directory_Name    => "icons",
              Template_Filename => "dirop.tmplt",
              Request           => Stat);
   begin
      Text_IO.Put_Line (Result);
   end;
end Dirop;
