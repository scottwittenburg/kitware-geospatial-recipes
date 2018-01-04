import os, unittest
import gaia
import geopandas


class TestGaiaInstall(unittest.TestCase):

    def test_read_file(self):
        fname = os.path.join(os.environ['RECIPE_DIR'], 'test_data', 'test.shp')
        df = geopandas.read_file(fname)
        bounds = df.total_bounds
        self.assertEqual(len(bounds), 4)

        # >>> df.total_bounds
        # array([-82.83,  25.35, -75.52,  36.18])

        self.assertGreater(bounds[0], -83)
        self.assertLess(bounds[0], -82)

        self.assertGreater(bounds[1], 25)
        self.assertLess(bounds[1], 26)

        self.assertGreater(bounds[2], -76)
        self.assertLess(bounds[2], -75)

        self.assertGreater(bounds[3], 36)
        self.assertLess(bounds[3], 37)

if __name__ == '__main__':
    unittest.main()
