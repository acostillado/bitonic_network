library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;
use ieee.std_logic_textio.all;


package Bitonic_Network_pkg is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant C_ELEMENT_WIDTH       : integer := 64;
  constant C_SORT_NETWORK_STAGES : integer := 2; -- random2bitonic + bitonic2sort
  constant C_PIPE_CYCLES         : integer := 2; -- internal network pipeline
  constant C_VELEMENTS           : integer := 16;
  constant C_NLANES              : integer := 8;
  constant C_NETWORK_INPUTS      : integer := 8;
  constant C_LOGnDEPTH           : integer := integer(ceil(log2(real(C_NETWORK_INPUTS))));
  constant C_NCOMP               : integer := C_LOGnDEPTH * C_NETWORK_INPUTS;

  -----------------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------------
  --type t_network_array is array (natural range <>) of std_logic_vector; -- Not supported in the simulator
  type t_network_array is array (natural range <>) of std_logic_vector(C_ELEMENT_WIDTH-1 downto 0);

  type t_direction_array is array (0 to 1) of string(1 to 5);
  --
  type t_muxConf1x4 is array (0 to 0) of std_logic_vector(3 downto 0);
  type t_muxConf2x2 is array (0 to 1) of std_logic_vector(1 downto 0);
  type t_muxConf4x1 is array (0 to 3) of std_logic_vector(0 downto 0);

  constant C_DIRECTION : t_direction_array := ("RIGHT", "LEFT ");  -- note the
                                                                   -- space
  -----------------------------------------------------------------------------
  -- Procedures
  -----------------------------------------------------------------------------


  procedure ReadFileDDR (
    constant file_name : in  string;
    constant lin_num   : in  integer;
    variable data_out  : out std_logic_vector(31 downto 0)
    );

  procedure WriteAXISfromFile (
    signal CLK         : in  std_logic;
    constant file_name : in  string;
    constant lin_num   : in  integer;
    signal WR_EN       : out std_logic;
    signal CS_EN       : out std_logic;
    signal WR_DATA     : out std_logic_vector(31 downto 0);
    signal ADDR        : out std_logic_vector(6 downto 0)
    );

end Bitonic_Network_pkg;

package body Bitonic_Network_pkg is

  procedure ReadFileDDR (

    constant file_name : in  string;
    constant lin_num   : in  integer;
    variable data_out  : out std_logic_vector(31 downto 0)
    ) is

    variable j, i         : integer   := 0;
    variable char         : character := '0';
    variable line_number  : line;
    variable line_content : string(1 to 8);

    file file_pointer : text;

  begin

    i := 1;
    file_open(file_pointer, file_name, read_mode);  --  "X:\FPGA_DJM\ddr.txt"
    while not endfile(file_pointer) loop
      readline(file_pointer, line_number);
      read(line_number, line_content);
      -- report "value of j is " & integer'image(j);

      if j = lin_num then
        for i in 0 to 7 loop
          char := line_content(8-i);
          if char = 'F' then
            data_out(3 + 4*i downto 4*i) := x"F";
          elsif char = 'E' then
            data_out(3 + 4*i downto 4*i) := x"E";
          elsif char = 'D' then
            data_out(3 + 4*i downto 4*i) := x"D";
          elsif char = 'C' then
            data_out(3 + 4*i downto 4*i) := x"C";
          elsif char = 'B' then
            data_out(3 + 4*i downto 4*i) := x"B";
          elsif char = 'A' then
            data_out(3 + 4*i downto 4*i) := x"A";
          elsif char = '9' then
            data_out(3 + 4*i downto 4*i) := x"9";
          elsif char = '8' then
            data_out(3 + 4*i downto 4*i) := x"8";
          elsif char = '7' then
            data_out(3 + 4*i downto 4*i) := x"7";
          elsif char = '6' then
            data_out(3 + 4*i downto 4*i) := x"6";
          elsif char = '5' then
            data_out(3 + 4*i downto 4*i) := x"5";
          elsif char = '4' then
            data_out(3 + 4*i downto 4*i) := x"4";
          elsif char = '3' then
            data_out(3 + 4*i downto 4*i) := x"3";
          elsif char = '2' then
            data_out(3 + 4*i downto 4*i) := x"2";
          elsif char = '1' then
            data_out(3 + 4*i downto 4*i) := x"1";
          elsif char = '0' then
            data_out(3 + 4*i downto 4*i) := x"0";
          else
            data_out := (others => '0');
          end if;
        end loop;

        wait for 10 ns;
      end if;
      j := j + 1;
    end loop;
    file_close(file_pointer);
    wait for 10 ns;

  end ReadFileDDR;


  procedure WriteAXISfromFile (
    signal CLK         : in  std_logic;
    constant file_name : in  string;
    constant lin_num   : in  integer;
    signal WR_EN       : out std_logic;
    signal CS_EN       : out std_logic;
    signal WR_DATA     : out std_logic_vector(31 downto 0);
    signal ADDR        : out std_logic_vector(6 downto 0)
    ) is

    variable V_WR_DATA : std_logic_vector(31 downto 0);

  begin
    wait until rising_edge(CLK);
    ReadFileDDR(file_name, lin_num, V_WR_DATA);
    wait until rising_edge(CLK);
    WR_DATA <= V_WR_DATA;
    WR_EN   <= '1';
    CS_EN   <= '1';
    ADDR    <= "0000100";
    wait until rising_edge(CLK);
    WR_DATA <= (others => '0');
    CS_EN   <= '0';
    WR_EN   <= '0';
    ADDR    <= (others => '0');
    for i in 0 to 14 loop
      wait until rising_edge(CLK);
    end loop;

  end WriteAXISfromFile;


end Bitonic_Network_pkg;
