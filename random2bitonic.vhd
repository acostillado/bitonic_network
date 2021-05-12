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
-- Description: Bitonic Network. Bitonic stage
-- 1) Create a bitonic sequence from a random input
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_misc.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.Bitonic_Network_pkg.all;


--entity random2bitonic is
--  generic(
--    G_ELEMENT_WIDTH  : integer := 64
--    );
--  port(
--    CLK         : in  std_logic;
--    RANDOM_IN   : in  t_network_array(0 to 7)(G_ELEMENT_WIDTH-1 downto 0);
--    BITONIC_OUT : out t_network_array(0 to 7)(G_ELEMENT_WIDTH-1 downto 0)
--    );
--end random2bitonic;

entity random2bitonic is
  generic(
    G_ELEMENT_WIDTH  : integer := 64
    );
  port(
    CLK         : in  std_logic;
    RANDOM_IN   : in  t_network_array(0 to 7);
    BITONIC_OUT : out t_network_array(0 to 7)
    );
end random2bitonic;

-------------------------------------------------------------------------------
-- Arch
-- Not using components anymore but using direct entity instantiation
-------------------------------------------------------------------------------

architecture RTL of random2bitonic is

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  constant C_SORT_NETWORK_DEPTH : integer := 8;  -- log^2 (8) (8=NUM_ELEM)
  constant C_NUM_ELEMENTS       : integer := 8;

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
  -- FIRST STAGE
  -----------------------------------------------------------------------------
  Inst_bitonic2elements1_0 : entity work.bitonic2elements
    generic map (
      G_DIRECTION => "RIGHT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => RANDOM_IN(0),
      TWO_ELEMENTS_IN(1)  => RANDOM_IN(1),
      TWO_ELEMENTS_OUT(0) => s_sort_node(0),
      TWO_ELEMENTS_OUT(1) => s_sort_node(1)
      );

  Inst_bitonic2elements1_1 : entity work.bitonic2elements
    generic map (
      G_DIRECTION => "LEFT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => RANDOM_IN(2),
      TWO_ELEMENTS_IN(1)  => RANDOM_IN(3),
      TWO_ELEMENTS_OUT(0) => s_sort_node(2),
      TWO_ELEMENTS_OUT(1) => s_sort_node(3)
      );

  Inst_bitonic2elements1_2 : entity work.bitonic2elements
    generic map (
      G_DIRECTION => "RIGHT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => RANDOM_IN(4),
      TWO_ELEMENTS_IN(1)  => RANDOM_IN(5),
      TWO_ELEMENTS_OUT(0) => s_sort_node(4),
      TWO_ELEMENTS_OUT(1) => s_sort_node(5)
      );

  Inst_bitonic2elements1_3 : entity work.bitonic2elements
    generic map (
      G_DIRECTION => "LEFT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => RANDOM_IN(6),
      TWO_ELEMENTS_IN(1)  => RANDOM_IN(7),
      TWO_ELEMENTS_OUT(0) => s_sort_node(6),
      TWO_ELEMENTS_OUT(1) => s_sort_node(7)
      );

  -----------------------------------------------------------------------------
  -- Second Stage
  -----------------------------------------------------------------------------

  Inst_bitonic4elements_1_0 : entity work.bitonic4elements
    generic map (
      G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
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
      G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
      G_REG_OUT   => 1,
      G_LENGTH    => 2,
      G_DIRECTION => "LEFT"
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
  Inst_bitonic2elements2_0 : entity work.bitonic2elements
    generic map (
      G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
      G_DIRECTION => "RIGHT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => s2_sort_node(0),
      TWO_ELEMENTS_IN(1)  => s2_sort_node(1),
      TWO_ELEMENTS_OUT(0) => BITONIC_OUT(0),
      TWO_ELEMENTS_OUT(1) => BITONIC_OUT(1)
      );

  Inst_bitonic2elements2_1 : entity work.bitonic2elements
    generic map (
      G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
      G_DIRECTION => "RIGHT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => s2_sort_node(2),
      TWO_ELEMENTS_IN(1)  => s2_sort_node(3),
      TWO_ELEMENTS_OUT(0) => BITONIC_OUT(2),
      TWO_ELEMENTS_OUT(1) => BITONIC_OUT(3)
      );

  Inst_bitonic2elements2_2 : entity work.bitonic2elements
    generic map (
      G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
      G_DIRECTION => "LEFT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => s2_sort_node(4),
      TWO_ELEMENTS_IN(1)  => s2_sort_node(5),
      TWO_ELEMENTS_OUT(0) => BITONIC_OUT(4),
      TWO_ELEMENTS_OUT(1) => BITONIC_OUT(5)
      );

  Inst_bitonic2elements2_3 : entity work.bitonic2elements
    generic map (
      G_ELEMENT_WIDTH => G_ELEMENT_WIDTH,
      G_DIRECTION => "LEFT"
      )
    port map (
      CLK                 => CLK,
      TWO_ELEMENTS_IN(0)  => s2_sort_node(6),
      TWO_ELEMENTS_IN(1)  => s2_sort_node(7),
      TWO_ELEMENTS_OUT(0) => BITONIC_OUT(6),
      TWO_ELEMENTS_OUT(1) => BITONIC_OUT(7)
      );

end architecture RTL;
