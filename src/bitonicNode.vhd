-------------------------------------------------------------------------------
-- Company     : Barcelona Supercomputing Center (BSC)
-- Engineer    : Daniel Jim?nez Mazure
-- *******************************************************************
-- File       : Bitonic_Network.vhd
-- Author     : $Autor: dasjimaz@gmail.com $
-- Date       : $Date: 2021-05-06 $
-- Revisions  : $Revision: $
-- Last update: 2021-05-15
-- *******************************************************************
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Bitonic sorting ot 8 elements using direcction as an input generic
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_misc.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.Bitonic_Network_pkg.all;

entity bitonicNode is
  generic (
    G_ELEMENT_WIDTH : integer := 64;
    G_REG_OUT       : integer := 0;
    G_LENGTH        : integer := 4;
    G_DIRECTION     : string  := "RIGHT"
    );
  port (
    CLK          : in  std_logic;
    CTRL         : in  std_logic_vector(G_LENGTH-1 downto 0);
    MUX_CONF     : out std_logic_vector(G_LENGTH-1 downto 0);
    ELEMENTS_IN  : in  t_network_array(0 to G_LENGTH * 2 - 1);
    ELEMENTS_OUT : out t_network_array(0 to G_LENGTH * 2 - 1)
    );
end bitonicNode;

-------------------------------------------------------------------------------
-- Arch
-- Not using components anymore but using direct entity instantiation
-------------------------------------------------------------------------------

architecture RTL of bitonicNode is

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- SIGNALS
  -----------------------------------------------------------------------------
  signal s_element_array : t_network_array(0 to G_LENGTH * 2 - 1);
  signal s_sort_node     : t_network_array(0 to G_LENGTH * 2 - 1);
  --
  signal CompGreaterThan : std_logic_vector(G_LENGTH-1 downto 0);
  signal CompControl     : std_logic_vector(G_LENGTH-1 downto 0);
  signal MuxConf         : std_logic_vector(G_LENGTH-1 downto 0);

begin  -- architecture RTL

  s_element_array <= ELEMENTS_IN;
  -----------------------------------------------------------------------------
  -- Sorting network
  -----------------------------------------------------------------------------

  GEN_RIGHT : if G_DIRECTION = "RIGHT" generate
    --
    --CompGreaterThan <= '1' when s_element_array(i) > s_element_array(i + G_LENGTH) else
    --                   '0';

    SORT_NET_RIGHT : process (s_element_array, s_sort_node)
    begin
      GEN_NODES : for i in 0 to G_LENGTH - 1 loop
        ---------------------------------------------------------------------------
        -- First Stage
        ---------------------------------------------------------------------------
        if s_element_array(i) > s_element_array(i + G_LENGTH) then
          s_sort_node(i)            <= s_element_array(i + G_LENGTH);
          s_sort_node(i + G_LENGTH) <= s_element_array(i);
          MuxConf(i)                <= '1';  -- cross
        else
          s_sort_node(i)            <= s_element_array(i);
          s_sort_node(i + G_LENGTH) <= s_element_array(i + G_LENGTH);
          MuxConf(i)                <= '0';  -- bypass
        end if;
      end loop;
    end process;
  end generate GEN_RIGHT;

  GEN_LEFT : if G_DIRECTION = "LEFT " generate
    --
    GEN_NODES : for i in 0 to G_LENGTH - 1 generate
      -- Compare
      CompGreaterThan(i) <= '1' when s_element_array(i) > s_element_array(i + G_LENGTH) else
                            '0';
      CompControl(i) <= CompGreaterThan(i) and CTRL(i);
      SORT_NET_LEFT : process (s_element_array, s_sort_node, CompControl)
      begin
        if CompControl(i) = '0' then
          s_sort_node(i)            <= s_element_array(i + G_LENGTH);
          s_sort_node(i + G_LENGTH) <= s_element_array(i);
          MuxConf(i)                <= '1';  -- cross
        else
          s_sort_node(i)            <= s_element_array(i);
          s_sort_node(i + G_LENGTH) <= s_element_array(i + G_LENGTH);
          MuxConf(i)                <= '0';  -- bypass
        end if;
      end process;
    end generate GEN_NODES;
  end generate GEN_LEFT;
-----------------------------------------------------------------------------
-- Generate Outputs
-----------------------------------------------------------------------------

  GEN_REG_OUT : if G_REG_OUT = 1 generate
    REG_PROC : process (CLK)
    begin
      if rising_edge(CLK) then
        ELEMENTS_OUT <= s_sort_node;
      end if;
    end process;
  end generate GEN_REG_OUT;

  GEN_OUT : if G_REG_OUT = 0 generate
    ELEMENTS_OUT <= s_sort_node;
  end generate GEN_OUT;

  MUX_CONF <= MuxConf;

end architecture RTL;

