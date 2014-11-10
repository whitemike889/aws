------------------------------------------------------------------------------
--                              Ada Web Server                              --
--                                                                          --
--                     Copyright (C) 2003-2015, AdaCore                     --
--                                                                          --
--  This library is free software;  you can redistribute it and/or modify   --
--  it under terms of the  GNU General Public License  as published by the  --
--  Free Software  Foundation;  either version 3,  or (at your  option) any --
--  later version. This library is distributed in the hope that it will be  --
--  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                    --
--                                                                          --
--  As a special exception under Section 7 of GPL version 3, you are        --
--  granted additional permissions described in the GCC Runtime Library     --
--  Exception, version 3.1, as published by the Free Software Foundation.   --
--                                                                          --
--  You should have received a copy of the GNU General Public License and   --
--  a copy of the GCC Runtime Library Exception along with this program;    --
--  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see   --
--  <http://www.gnu.org/licenses/>.                                         --
--                                                                          --
--  As a special exception, if other files instantiate generics from this   --
--  unit, or you link this unit with other files to produce an executable,  --
--  this  unit  does not  by itself cause  the resulting executable to be   --
--  covered by the GNU General Public License. This exception does not      --
--  however invalidate any other reasons why the executable file  might be  --
--  covered by the  GNU Public License.                                     --
------------------------------------------------------------------------------

with AWS.Client;

with SOAP.Name_Space;
with SOAP.WSDL.Parameters;
with SOAP.WSDL.Parser;

private with Ada.Strings.Unbounded;

package SOAP.Generator is

   use AWS;

   Version : constant String := "2.4.0";

   Generator_Error : exception;

   type Object is new SOAP.WSDL.Parser.Object with private;

   overriding procedure Start_Service
     (O                  : in out Object;
      Name               : String;
      Root_Documentation : String;
      Documentation      : String;
      Location           : String);
   --  Called for every service in the WSDL document

   overriding procedure End_Service
     (O    : in out Object;
      Name : String);
   --  Called at the end of the service

   overriding procedure New_Procedure
     (O             : in out Object;
      Proc          : String;
      Documentation : String;
      SOAPAction    : String;
      Namespace     : Name_Space.Object;
      Input         : WSDL.Parameters.P_Set;
      Output        : WSDL.Parameters.P_Set;
      Fault         : WSDL.Parameters.P_Set);
   --  Called for each SOAP procedure found in the WSDL document for the
   --  current service.

   -----------
   -- Query --
   -----------

   function Procs_Spec (O : Object) return String;
   --  Returns the spec where SOAP service procedures are defined

   function Types_Spec (O : Object) return String;
   --  Returns the spec where SOAP types are defined

   --------------
   -- Settings --
   --------------

   procedure Quiet (O : in out Object);
   --  Set quiet mode (default off)

   procedure No_Stub (O : in out Object);
   --  Do not generate stub (stub generated by default)

   procedure No_Skel (O : in out Object);
   --  Do not generate skeleton (skeleton generated by default)

   procedure Gen_CB (O : in out Object);
   --  Generate SOAP callback for all routines

   procedure Ada_Style (O : in out Object);
   --  Use Ada style identifier, by default the WSDL casing is used

   procedure Endpoint (O : in out Object; URL : String);
   --  Set default endpoint to use instead of the one specified in the WSDL
   --  document.

   procedure Specs_From (O : in out Object; Spec : String);
   --  Use type definitions for Array and Record and SOAP services procedure
   --  from this Ada spec. This requires that all record definitions are
   --  insided this spec. This options is useful when generating stub/skeleton
   --  from a WSDL document generated with ada2wsdl. In this case the types
   --  definition are already coded in Ada, it is preferable to reuse them to
   --  not have to convert to/from both definitions.

   procedure Types_From (O : in out Object; Spec : String);
   --  Use type definitions for Array and Record from this Ada spec instead of
   --  the one defined above. If there is no spec defined above, the procs are
   --  also used from this spec.

   procedure Main (O : in out Object; Name : String);
   --  Set the main program to be generated. This is useful for simple server.
   --  Main can be specified only if the SOAP callbacks are generated.

   procedure CVS_Tag (O : in out Object);
   --  Add CVS tag Id in the unit header (no CVS by default)

   procedure WSDL_File (O : in out Object; Filename : String);
   --  Add WSDL file in parent file comments (no WSDL by default)

   procedure Options (O : in out Object; Options : String);
   --  Set options used with wsdl2aws tool to generate the code

   procedure Overwrite (O : in out Object);
   --  Add WSDL file in parent file comments (no overwriting by default)

   procedure Set_Proxy (O : in out Object; Proxy, User, Password : String);
   --  Set proxy user and password, needed if behind a firewall with
   --  authentication.

   procedure Set_Timeouts
     (O        : in out Object;
      Timeouts : Client.Timeouts_Values);
   --  Set the SOAP call timeouts

   procedure Debug (O : in out Object);
   --  Activate the debug code generator

private

   use Ada.Strings.Unbounded;

   type Object is new SOAP.WSDL.Parser.Object with record
      Quiet      : Boolean := False;
      Gen_Stub   : Boolean := True;
      Gen_Skel   : Boolean := True;
      Gen_CB     : Boolean := False;
      Ada_Style  : Boolean := False;
      CVS_Tag    : Boolean := False;
      Force      : Boolean := False;
      First_Proc : Boolean := True;
      Debug      : Boolean := False;
      Unit       : Unbounded_String;
      Spec       : Unbounded_String;
      Types_Spec : Unbounded_String;
      Main       : Unbounded_String;
      Location   : Unbounded_String;
      WSDL_File  : Unbounded_String;
      Proxy      : Unbounded_String;
      P_User     : Unbounded_String;
      P_Pwd      : Unbounded_String;
      Options    : Unbounded_String;
      Endpoint   : Unbounded_String;
      Timeouts   : Client.Timeouts_Values := Client.No_Timeout;
   end record;

end SOAP.Generator;
