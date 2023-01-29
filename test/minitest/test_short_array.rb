require_relative '../minitest_helper'
require_relative 'test_display_string'

module ResponsiveConsole
  class TestShortArray < Minitest::Test
    include TestDisplayString

    def setup
      ArrayFormatter::FORMATS[:test] = "[  %E, %E  ]"
      super
    end

    def test_nested_arrays
      assert_equal(subject_output(@nested_array), <<~TEXT.strip)
        [  [  "A___________________________", "B____________________________",
              "C_____________________________", "D______________________________",
              "E_______________________________", "F________________________________",
              "G_________________________________", "H___________________________"  ],
           [  "I____________________________", "J_____________________________",
              "K______________________________", "L_______________________________",
              "M________________________________", "N_________________________________",
              "O___________________________", "P____________________________"  ],
           [  "Q_____________________________", "R______________________________",
              "S_______________________________", "T________________________________",
              "U_________________________________", "V___________________________",
              "W____________________________", "X_____________________________"  ]  ]
      TEXT
    end

    def test_hashes_with_array_values
      assert_equal(subject_output(@array_values), <<~TEXT.strip)
        A___________________________:
          [  "B____________________________", "C_____________________________",
             "D______________________________", "E_______________________________",
             "F________________________________", "G_________________________________",
             "H___________________________"  ]
        I____________________________:
          [  "J_____________________________", "K______________________________",
             "L_______________________________", "M________________________________",
             "N_________________________________", "O___________________________",
             "P____________________________"  ]
        Q_____________________________:
          [  "R______________________________", "S_______________________________",
             "T________________________________", "U_________________________________",
             "V___________________________", "W____________________________",
             "X_____________________________"  ]
      TEXT
    end

    def test_hashes_with_array_keys
      assert_equal(subject_output(@array_keys), <<~TEXT.strip)
        [  "B____________________________", "C_____________________________",
           "D______________________________", "E_______________________________",
           "F________________________________", "G_________________________________",
           "H___________________________"  ]:
          "A___________________________"
        [  "J_____________________________", "K______________________________",
           "L_______________________________", "M________________________________",
           "N_________________________________", "O___________________________",
           "P____________________________"  ]:
          "I____________________________"
        [  "R______________________________", "S_______________________________",
           "T________________________________", "U_________________________________",
           "V___________________________", "W____________________________",
           "X_____________________________"  ]:
          "Q_____________________________"
      TEXT
    end
  end
end
