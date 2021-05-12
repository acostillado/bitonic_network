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
-- Description: Bitonic sorting of 2 elements using direcction as an input generic
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_misc.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.Bitonic_Network_pkg.all;

--entity bitonic2elements is
--  generic(
--    G_ELEMENT_WIDTH  : integer := 64;
--    G_REG_OUT        : integer := 0;
--    G_DIRECTION      : string  := "RIGHT"
--    );
--  port(
--    CLK              : in  std_logic;
--    TWO_ELEMENTS_IN  : in  t_network_array(0 to 1)(G_ELEMENT_WIDTH-1 downto 0);
--    TWO_ELEMENTS_OUT : out t_network_array(0 to 1)(G_ELEMENT_WIDTH-1 downto 0)
--    );
--end bitonic2elements;

entity bitonic2elements is
  generic(
    G_ELEMENT_WIDTH  : integer := 64;
    G_REG_OUT        : integer := 0;
    G_DIRECTION      : string  := "RIGHT"
    );
  port(
    CLK              : in  std_logic;
    TWO_ELEMENTS_IN  : in  t_network_array(0 to 1);
    TWO_ELEMENTS_OUT : out t_network_array(0 to 1)
    );
end bitonic2elements;

-------------------------------------------------------------------------------
-- Arch
-- Not using components anymore but using direct entity instantiation
-------------------------------------------------------------------------------

architecture RTL of bitonic2elements is

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  constant C_NUM_ELEMENTS : integer := 2;
  -----------------------------------------------------------------------------
  -- SIGNALS
  -----------------------------------------------------------------------------
--  signal s_element_array  : t_network_array(0 to 1)(G_ELEMENT_WIDTH-1 downto 0);
--  signal s_sort_node      : t_network_array(0 to 1)(G_ELEMENT_WIDTH-1 downto 0);
  signal s_element_array  : t_network_array(0 to 1);
  signal s_sort_node      : t_network_array(0 to 1);

begin  -- architecture RTL


  s_element_array <= TWO_ELEMENTS_IN;


  -----------------------------------------------------------------------------
  -- Sorting network
  -----------------------------------------------------------------------------

  GEN_RIGHT : if G_DIRECTION = "RIGHT" generate
    --
    SORT_NET_RIGHT : process(s_element_array, s_sort_node)
    begin
      ---------------------------------------------------------------------------
      -- First Stage
      ---------------------------------------------------------------------------
      if s_element_array(0) > s_element_array(1) then
        s_sort_node(0) <= s_element_array(1);
        s_sort_node(1) <= s_element_array(0);
      else
        s_sort_node(0) <= s_element_array(0);
        s_sort_node(1) <= s_element_array(1);
      end if;
    end process;
  end generate GEN_RIGHT;


  GEN_LEFT : if G_DIRECTION = "LEFT" generate
    --
    SORT_NET_LEFT : process(s_element_array, s_sort_node)
    begin
      ---------------------------------------------------------------------------
      -- First Stage
      ---------------------------------------------------------------------------

      if s_element_array(0) > s_element_array(1) then
        s_sort_node(0) <= s_element_array(0);
        s_sort_node(1) <= s_element_array(1);
      else
        s_sort_node(0) <= s_element_array(1);
        s_sort_node(1) <= s_element_array(0);
      end if;

    end process;

  end generate GEN_LEFT;

  -----------------------------------------------------------------------------
  -- Generate Outputs
  -----------------------------------------------------------------------------

  GEN_REG_OUT : if G_REG_OUT = 1 generate
    REG_PROC : process(CLK)
    begin
      if rising_edge(CLK) then
        TWO_ELEMENTS_OUT <= s_sort_node;
      end if;
    end process;
  end generate GEN_REG_OUT;

  GEN_OUT : if G_REG_OUT = 0 generate
    TWO_ELEMENTS_OUT <= s_sort_node;
  end generate GEN_OUT;


end architecture RTL;
