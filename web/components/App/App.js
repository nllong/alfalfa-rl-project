import React from 'react';
import PropTypes from 'prop-types';
import { Component } from 'react';
import { Link, Route, Switch } from 'react-router-dom';
import IconButton from 'material-ui/IconButton';
import {FileCloudQueue, FileCloudDone, ActionAccountCircle} from 'material-ui-icons';
//import {MuiThemeProvider} from 'material-ui/styles';
import Toolbar from 'material-ui/Toolbar';
import AppBar from 'material-ui/AppBar';
import Badge from 'material-ui/Badge';
import Upload from '../Upload/Upload.js';
import Sites from '../Sites/Sites.js';
import Typography from 'material-ui/Typography';
import { withStyles } from 'material-ui/styles';
import Grid from 'material-ui/Grid';

const styles = {
  root: {
    display: 'flex',
    flexDirection: 'column',
    minHeight: '100vh',
  },
  title: {
    flex: 1,
  },
};

class App extends React.Component {
  render = () => {
    return (
        <div className={this.props.classes.root}>
          <AppBar position="static">
            <Toolbar>
              <Link to={'/'} className={this.props.classes.title} style={{ textDecoration: 'none', color: 'unset' }}> 
                <Typography type="title" color="inherit">Alfalfa</Typography>
              </Link>
              <Grid container justify='flex-end'>
                <Grid item>
                  <Link to={'/sites'} style={{ textDecoration: 'none', color: 'unset' }}>
                    <Typography type="button" color="inherit">Sites</Typography>
                  </Link>
                </Grid>
                <Grid item>
                  <Link to={'/simulations'} style={{ textDecoration: 'none', color: 'unset' }}>
                    <Typography type="button" color="inherit">Simulations</Typography>
                  </Link>
                </Grid>
              </Grid>
            </Toolbar>
          </AppBar>
          <Switch>
            <Route path="/sites" component={Sites}/>
            <Route component={Upload}/>
          </Switch>
        </div>
    );
  }
};

App.propTypes = {
  classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(App);

