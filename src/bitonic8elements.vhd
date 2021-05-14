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

--entity bitonic8elements is
--  generic(
--    G_NETWORK_INPUTS : integer := 8;
--    G_ELEMENT_WIDTH  : integer := 64;
--    G_REG_OUT        : integer := 0;
--    G_LENGTH         : integer := 4;
--    G_DIRECTION      : string  := "RIGHT"
--    );
--  port(
--    CLK                : in  std_logic;
--    EIGHT_ELEMENTS_IN  : in  t_network_array(0 to 7)(G_ELEMENT_WIDTH-1 downto 0);
--    EIGHT_ELEMENTS_OUT : out t_network_array(0 to 7)(G_ELEMENT_WIDTH-1 downto 0)
--    );
--end bitonic8elements;

entity bitonic8elements is
  generic(
    G_NETWORK_INPUTS : integer := 8;
    G_ELEMENT_WIDTH  : integer := 64;
    G_REG_OUT        : integer := 0;
    G_LENGTH         : integer := 4;
    G_DIRECTION      : string  := "RIGHT"
    );
  port(
    CLK                : in  std_logic;
    EIGHT_ELEMENTS_IN  : in  t_network_array(0 to 7);
    EIGHT_ELEMENTS_OUT : out t_network_array(0 to 7)
    );
end bitonic8elements;

-------------------------------------------------------------------------------
-- Arch
-- Not using components anymore but using direct entity instantiation
-------------------------------------------------------------------------------

architecture RTL of bitonic8elements is

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- SIGNALS
  -----------------------------------------------------------------------------
--  signal s_pixel_array : t_network_array(0 to 7)(G_ELEMENT_WIDTH-1 downto 0);
--  signal s_sort_node   : t_network_array(0 to 7)(G_ELEMENT_WIDTH-1 downto 0);
  signal s_pixel_array : t_network_array(0 to 7);
  signal s_sort_node   : t_network_array(0 to 7);

begin  -- architecture RTL


  s_pixel_array <= EIGHT_ELEMENTS_IN;


  -----------------------------------------------------------------------------
  -- Sorting network
  -----------------------------------------------------------------------------

  GEN_RIGHT : if G_DIRECTION = "RIGHT" generate
    --
    SORT_NET_RIGHT : process(s_pixel_array, s_sort_node)
    begin
      GEN_NODES : for i in 0 to 3 loop
        ---------------------------------------------------------------------------
        -- First Stage
        ---------------------------------------------------------------------------
        if s_pixel_array(i) > s_pixel_array(i+G_LENGTH) then
          s_sort_node(i)          <= s_pixel_array(i+G_LENGTH);
          s_sort_node(i+G_LENGTH) <= s_pixel_array(i);
        else
          s_sort_node(i)          <= s_pixel_array(i);
          s_sort_node(i+G_LENGTH) <= s_pixel_array(i+G_LENGTH);
        end if;
      end loop;
    end process;
  end generate GEN_RIGHT;


  GEN_LEFT : if G_DIRECTION = "LEFT" generate
    --
    SORT_NET_LEFT : process(s_pixel_array, s_sort_node)
    begin
      GEN_NODES : for i in 0 to 3 loop
        ---------------------------------------------------------------------------
        -- First Stage
        ---------------------------------------------------------------------------
        if s_pixel_array(i) < s_pixel_array(i+G_LENGTH) then
          s_sort_node(i)          <= s_pixel_array(i+G_LENGTH);
          s_sort_node(i+G_LENGTH) <= s_pixel_array(i);
        else
          s_sort_node(i)          <= s_pixel_array(i);
          s_sort_node(i+G_LENGTH) <= s_pixel_array(i+G_LENGTH);
        end if;
      end loop;
    end process;
  end generate GEN_LEFT;


  -----------------------------------------------------------------------------
  -- Generate Outputs
  -----------------------------------------------------------------------------

  GEN_REG_OUT : if G_REG_OUT = 1 generate
    REG_PROC : process(CLK)
    begin
      if rising_edge(CLK) then
        EIGHT_ELEMENTS_OUT <= s_sort_node;
      end if;
    end process;
  end generate GEN_REG_OUT;

  GEN_OUT : if G_REG_OUT = 0 generate
    EIGHT_ELEMENTS_OUT <= s_sort_node;
  end generate GEN_OUT;



end architecture RTL;
