-------------------------------------------------------------------------------
-- Company     : Barcelona Supercomputing Center (BSC)
-- Engineer    : Daniel Jiménez Mazure
-- *******************************************************************
-- File       : Bitonic_Network.vhd
-- Author     : $Autor: dasjimaz@gmail.com $
-- Date       : $Date: 2021-05-06 $
-- Revisions  : $Revision: $
-- Last update: 2021-05-07
-- *******************************************************************
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Bitonic Network. Merge stage:
-- 1) Sort a Bitonic sequence 
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_misc.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.Bitonic_Network_pkg.all;


--entity bitonic2sort is
--  generic(
--    G_ELEMENT_WIDTH  : integer := 64
--    );
--  port(
--    CLK        : in  std_logic;
--    BITONIC_IN : in  t_network_array(0 to 7)(G_ELEMENT_WIDTH-1 downto 0);
--    SORTED_OUT : out t_network_array(0 to 7)(G_ELEMENT_WIDTH-1 downto 0)
--    );
--end bitonic2sort;

entity bitonic2sort is
  generic(
    G_ELEMENT_WIDTH  : integer := 64
    );
  port(
    CLK        : in  std_logic;
    BITONIC_IN : in  t_network_array(0 to 7);
    SORTED_OUT : out t_network_array(0 to 7)
    );
end bitonic2sort;

-------------------------------------------------------------------------------
-- Arch
-- Not using components anymore but using direct entity instantiation
-------------------------------------------------------------------------------

architecture RTL of bitonic2sort is

  -----------------------------------------------------------------------------
  -- SIGNALS
  -----------------------------------------------------------------------------
  --
--  signal s_sort_node  : t_network_array(0 to 7)(G_ELEMENT_WIDTH-1 downto 0);  
--  signal s2_sort_node : t_network_array(0 to 7)(G_ELEMENT_WIDTH-1 downto 0);  
--  signal s3_sort_node : t_network_array(0 to 7)(G_ELEMENT_WIDTH-1 downto 0);

 signal s_sort_node  : t_network_array(0 to 7);  
 signal s2_sort_node : t_network_array(0 to 7);  
 signal s3_sort_node : t_network_array(0 to 7);

begin  -- architecture RTL

  -----------------------------------------------------------------------------
  -- First Stage
  -----------------------------------------------------------------------------
  Inst_bitonic8elements_0_0 : entity work.bitonic8elements
    generic map (
      G_LENGTH    => 4,
      G_DIRECTION => "RIGHT"
      )
    port map (
      CLK                => CLK,
      EIGHT_ELEMENTS_IN  => BITONIC_IN,
      EIGHT_ELEMENTS_OUT => s_sort_node
      );


  -----------------------------------------------------------------------------
  -- Second Stage
  -----------------------------------------------------------------------------

  Inst_bitonic4elements_1_0 : entity work.bitonic4elements
    generic map (
      G_REG_OUT   => 1,
      G_LENGTH    => 2,
      G_DIRECTION => "RIGHT"
      )
    port map (
      CLK                  => CLK,
      FOUR_ELEMENTS_IN(0)  => s_sort_node(0),
      FOUR_ELEMENTS_IN(1)  => s_sort_node(1),
      FOUR_ELEMENTS_IN(2)  => s_sort_node(2),
      FOUR_ELEMENTS_IN(3)  => s_sort_node(3),
      FOUR_ELEMENTS_OUT(0) => s2_sort_node(0),
      FOUR_ELEMENTS_OUT(1) => s2_sort_node(1),
      FOUR_ELEMENTS_OUT(2) => s2_sort_node(2),
      FOUR_ELEMENTS_OUT(3) => s2_sort_node(3)
      );

  Inst_bitonic4elements_1_1 : entity work.bitonic4elements
    generic map (
      G_REG_OUT   => 1,
      G_LENGTH    => 2,
      G_DIRECTION => "RIGHT"
      )
    port map (
      CLK                  => CLK,
      FOUR_ELEMENTS_IN(0)  => s_sort_node(4),
      FOUR_ELEMENTS_IN(1)  => s_sort_node(5),
      FOUR_ELEMENTS_IN(2)  => s_sort_node(6),
      FOUR_ELEMENTS_IN(3)  => s_sort_node(7),
      FOUR_ELEMENTS_OUT(0) => s2_sort_node(4),
      FOUR_ELEMENTS_OUT(1) => s2_sort_node(5),
      FOUR_ELEMENTS_OUT(2) => s2_sort_node(6),
      FOUR_ELEMENTS_OUT(3) => s2_sort_node(7)
      );

  -----------------------------------------------------------------------------
  -- Third Stage
  -----------------------------------------------------------------------------
  Inst_bitonic2elements_2_0 : entity work.bitonic2elements
    generic map (
      G_DIRECTION => "RIGHT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => s2_sort_node(0),
      TWO_ELEMENTS_IN(1)  => s2_sort_node(1),
      TWO_ELEMENTS_OUT(0) => SORTED_OUT(0),
      TWO_ELEMENTS_OUT(1) => SORTED_OUT(1)
      );

  Inst_bitonic2elements_2_1 : entity work.bitonic2elements
    generic map (
      G_DIRECTION => "RIGHT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => s2_sort_node(2),
      TWO_ELEMENTS_IN(1)  => s2_sort_node(3),
      TWO_ELEMENTS_OUT(0) => SORTED_OUT(2),
      TWO_ELEMENTS_OUT(1) => SORTED_OUT(3)
      );

  Inst_bitonic2elements_2_2 : entity work.bitonic2elements
    generic map (
      G_DIRECTION => "RIGHT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => s2_sort_node(4),
      TWO_ELEMENTS_IN(1)  => s2_sort_node(5),
      TWO_ELEMENTS_OUT(0) => SORTED_OUT(4),
      TWO_ELEMENTS_OUT(1) => SORTED_OUT(5)
      );

  Inst_bitonic2elements_2_3 : entity work.bitonic2elements
    generic map (
      G_DIRECTION => "RIGHT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => s2_sort_node(6),
      TWO_ELEMENTS_IN(1)  => s2_sort_node(7),
      TWO_ELEMENTS_OUT(0) => SORTED_OUT(6),
      TWO_ELEMENTS_OUT(1) => SORTED_OUT(7)
      );

end architecture RTL;
